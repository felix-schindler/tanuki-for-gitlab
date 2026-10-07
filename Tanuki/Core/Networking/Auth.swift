//
//  Auth.swift
//  Tanuki
//
//  Created by Felix Schindler on 03.10.25.
//

import Alamofire
import Apollo
import CryptoKit
import Foundation
import SwiftUI

enum AuthError: LocalizedError {
	case notRefreshable

	var errorDescription: String? {
		switch self {
		case .notRefreshable:
			return "The session can't be refreshed. Please log in again."
		}
	}
}

@MainActor
class Auth {
	public static let clientID = "9ee458e1f3cca37c7d9c6651da1caa5d242ce9988e08471e7cba278cbe2eced2"
	public static let scope = "api+read_repository"
	public static let redirectUri = "tanuki://oauth/callback"

	public static func generateCodeVerifier() -> String {
		let length = Int.random(in: 43...128)
		let characters = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
		var result = ""
		for _ in 0..<length {
			result.append(characters.randomElement()!)
		}
		return result
	}

	public static func generateCodeChallenge(codeVerifier: String) -> String {
		let data = Data(codeVerifier.utf8)
		let digest = SHA256.hash(data: data)
		let sha256Data = Data(digest)

		let base64 = sha256Data.base64EncodedString()
			.replacingOccurrences(of: "+", with: "-")
			.replacingOccurrences(of: "/", with: "_")
			.replacingOccurrences(of: "=", with: "")

		return base64
	}

	public static func login(
		instance: GitLabInstance,
		showSetup: Binding<Bool>? = nil,
		dismiss: DismissAction? = nil
	) async throws {
		let previousInstance = InstanceManager.selected
		InstanceManager.add(instance)
		try await resetSessionCaches()

		do {
			let user = try await API.get(
				type: RestAPIUser.self,
				endpoint: "user"
			)

			Notify.status(
				.success,
				"Welcome, \(user.username)",
				systemImage: "checkmark"
			)
			showSetup?.wrappedValue = false
			dismiss?()
			SessionStore.shared.refresh()
		} catch {
			InstanceManager.remove(instance)
			if let previousInstance {
				InstanceManager.select(previousInstance)
				try await resetSessionCaches()
			}
			SessionStore.shared.refresh()
			throw error
		}
	}

	public static func logout(showSetup: Binding<Bool>? = nil) async {
		if let current = InstanceManager.selected {
			InstanceManager.remove(current)
		}

		do {
			try await resetSessionCaches()
			Notify.status(.success, "Logged out")

			if InstanceManager.selected == nil {
				showSetup?.wrappedValue = true
			}
			SessionStore.shared.refresh()
		} catch let error {
			Notify.status(
				.error,
				"Failed to log out",
				error.localizedDescription
			)
		}
	}

	public static func switchInstance(to instance: GitLabInstance) async {
		InstanceManager.select(instance)

		do {
			try await resetSessionCaches()
			let user = try await API.get(
				type: RestAPIUser.self,
				endpoint: "user"
			)
			Notify.status(
				.success,
				"Switched to \(user.username)",
				systemImage: "checkmark"
			)
			SessionStore.shared.refresh()
		} catch let error {
			Notify.status(
				.error,
				"Failed to switch instance",
				error.localizedDescription,
				systemImage: "xmark"
			)
		}
	}

	private static func resetSessionCaches() async throws {
		URLCache.shared.removeAllCachedResponses()
		URLCache.avatar.removeAllCachedResponses()
		Network.shared.resetApolloClient()
		try await Network.shared.apollo.store.clearCache()
	}

	// MARK: - Initial login (OAuth)

	/// Exchanges the authorization code returned by ``OAuth`` for a token pair.
	public static func exchangeAuthorizationCode(
		code: String,
		codeVerifier: String,
		host: String
	) async throws -> OAuthToken {
		try await API.req(
			type: OAuthToken.self,
			method: .post,
			endpoint: "oauth/token",
			body: [
				"client_id": Auth.clientID,
				"code": code,
				"grant_type": "authorization_code",
				"redirect_uri": Auth.redirectUri,
				"code_verifier": codeVerifier,
			],
			contentType: .formUrlEncoded,
			auth: false,
			useBase: false,
			host: host
		)
	}

	// MARK: - Token refresh (OAuth)
	private static var refreshTask: Task<OAuthToken, Error>?

	public static func ensureValidToken() async {
		guard let instance = InstanceManager.selected, instance.needsTokenRefresh else {
			return
		}

		do {
			_ = try await refreshAccessToken()
			logger.debug("OAuth token renewed in the background")
		} catch {
			if isUnrecoverable(error) {
				await logoutDueToUnauthorized(instanceId: instance.id)
			} else {
				logger.error("Background token renewal failed, keeping session — \(error.localizedDescription)")
			}
		}
	}

	public static func refreshAccessToken() async throws -> String {
		if let refreshTask {
			return try await refreshTask.value.accessToken
		}

		guard let instance = InstanceManager.selected,
			instance.isOAuth,
			let refreshToken = instance.refreshToken,
			refreshToken.isNotEmpty
		else {
			throw AuthError.notRefreshable
		}

		let instanceId = instance.id
		let host = instance.host
		let task = Task<OAuthToken, Error> { @MainActor in
			try await API.req(
				type: OAuthToken.self,
				method: .post,
				endpoint: "oauth/token",
				body: [
					"client_id": Auth.clientID,
					"refresh_token": refreshToken,
					"grant_type": "refresh_token",
					"redirect_uri": Auth.redirectUri,
				],
				contentType: .formUrlEncoded,
				auth: false,
				useBase: false,
				host: host
			)
		}
		refreshTask = task

		do {
			let token = try await task.value
			refreshTask = nil
			if InstanceManager.selected?.id == instanceId {
				InstanceManager.update(
					GitLabInstance(
						host: host,
						token: token.accessToken,
						isOAuth: true,
						refreshToken: token.refreshToken,
						expiresAt: token.expiresAt
					)
				)
			}
			return token.accessToken
		} catch {
			refreshTask = nil
			throw error
		}
	}

	public static func handleUnauthorized(instanceId: String) async -> String? {
		guard let current = InstanceManager.selected, current.id == instanceId else {
			return nil
		}

		if current.isOAuth, current.refreshToken?.isNotEmpty == true {
			do {
				let token = try await refreshAccessToken()
				guard InstanceManager.selected?.id == instanceId else {
					return nil
				}
				logger.info("Recovered from 401 with a silent token renewal")
				return token
			} catch {
				if isUnrecoverable(error) {
					await logoutDueToUnauthorized(instanceId: instanceId)
				} else {
					logger.error(
						"Token renewal failed, keeping session — \(error.localizedDescription)"
					)
				}
				return nil
			}
		}

		await logoutDueToUnauthorized(instanceId: instanceId)
		return nil
	}

	public static func logoutDueToUnauthorized(instanceId: String) async {
		guard let current = InstanceManager.selected, current.id == instanceId else {
			return
		}

		logger.warning("Token invalid (401) — removing instance \(instanceId)")
		InstanceManager.remove(current)
		do {
			try await resetSessionCaches()
		} catch {
			logger.error("Failed to clear caches on logout — \(error.localizedDescription)")
		}
		Notify.status(
			.error,
			"Session expired",
			"You have been logged out. Please log in again.",
			systemImage: "xmark"
		)
		SessionStore.shared.refresh()
	}

	nonisolated private static func isUnrecoverable(_ error: Error) -> Bool {
		if error is AuthError {
			return true
		}
		if let apiError = error as? APIError, case .http(let status, _) = apiError {
			return status == 400 || status == 401
		}
		return false
	}

	nonisolated public static func isUnauthorized(_ error: Error) -> Bool {
		if let apiError = error as? APIError, apiError.isUnauthorized {
			return true
		}
		if let responseError = error as? ResponseCodeInterceptor.ResponseCodeError {
			return responseError.response.statusCode == 401
		}
		return false
	}
}
