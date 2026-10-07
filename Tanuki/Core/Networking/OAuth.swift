//
//  OAuth.swift
//  Tanuki
//
//  Created by Felix Schindler on 07.10.26.
//

import AuthenticationServices
import Foundation
import SwiftUI

enum OAuthError: LocalizedError {
	case invalidRequest
	case malformedCallback
	case stateMismatch
	case cancelled

	var errorDescription: String? {
		switch self {
		case .invalidRequest:
			return "Couldn't build the GitLab authorization URL."
		case .malformedCallback:
			return "GitLab returned an unexpected response."
		case .stateMismatch:
			return "State mismatch"
		case .cancelled:
			return "Login was cancelled."
		}
	}
}

/// Runs the GitLab OAuth authorization-code flow with PKCE.
///
/// SwiftUI's `WebAuthenticationSession` presents the browser and hands the callback back to the matching
/// `authenticate` call, so `state` and the PKCE verifier live in that call's frame for the whole
/// round-trip. Nothing is stored on a view, so re-creating the view cannot invalidate them.
@MainActor
enum OAuth {
	/// Presents the authorize page for `host` and exchanges the returned code for tokens.
	static func authorize(
		using session: WebAuthenticationSession,
		host: String = "gitlab.com"
	) async throws -> OAuthToken {
		let state = UUID().uuidString
		let codeVerifier = Auth.generateCodeVerifier()

		let callback: URL
		do {
			callback = try await requestAuthorization(
				using: session,
				host: host,
				state: state,
				codeChallenge: Auth.generateCodeChallenge(codeVerifier: codeVerifier)
			)
		} catch {
			throw mapToOAuthError(error)
		}

		let code = try authorizationCode(from: callback, matchingState: state)

		return try await Auth.exchangeAuthorizationCode(
			code: code,
			codeVerifier: codeVerifier,
			host: host
		)
	}

	// MARK: - Authorization request

	private static func requestAuthorization(
		using session: WebAuthenticationSession,
		host: String,
		state: String,
		codeChallenge: String
	) async throws -> URL {
		guard let callbackScheme = URL(string: Auth.redirectUri)?.scheme else {
			throw OAuthError.invalidRequest
		}

		var components = URLComponents()
		components.scheme = "https"
		components.host = host
		components.path = "/oauth/authorize"
		components.queryItems = [
			URLQueryItem(name: "client_id", value: Auth.clientID),
			URLQueryItem(name: "code_challenge", value: codeChallenge),
			URLQueryItem(name: "code_challenge_method", value: "S256"),
			URLQueryItem(name: "redirect_uri", value: Auth.redirectUri),
			URLQueryItem(name: "response_type", value: "code"),
			URLQueryItem(name: "scope", value: Auth.scope),
			URLQueryItem(name: "state", value: state),
		]

		guard let url = components.url else {
			throw OAuthError.invalidRequest
		}

		// `.shared` reuses an existing gitlab.com session from Safari; `additionalHeaderFields` has no default.
		return try await session.authenticate(
			using: url,
			callback: .customScheme(callbackScheme),
			preferredBrowserSession: .shared,
			additionalHeaderFields: [:]
		)
	}

	// MARK: - Callback validation

	private static func authorizationCode(from callback: URL, matchingState state: String) throws -> String {
		guard let components = URLComponents(url: callback, resolvingAgainstBaseURL: false),
			let queryItems = components.queryItems
		else {
			throw OAuthError.malformedCallback
		}

		guard queryItems.first(where: { $0.name == "state" })?.value == state else {
			throw OAuthError.stateMismatch
		}

		guard let code = queryItems.first(where: { $0.name == "code" })?.value, code.isNotEmpty else {
			throw OAuthError.malformedCallback
		}

		return code
	}

	private static func mapToOAuthError(_ error: Error) -> Error {
		if (error as? ASWebAuthenticationSessionError)?.code == .canceledLogin {
			return OAuthError.cancelled
		}
		return error
	}
}
