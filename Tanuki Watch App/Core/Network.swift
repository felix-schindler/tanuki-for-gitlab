//
//  Network.swift
//  Tanuki
//
//  Created by Felix Schindler on 26.02.24.
//

import Apollo
import ApolloAPI
import Foundation
import SwiftUI
import WatchConnectivity

struct GitLabInstance: Codable, Identifiable, Equatable, Sendable {
	var id: String { host }
	let host: String
	let token: String
	let isOAuth: Bool
	let refreshToken: String?
	let expiresAt: Date?

	init(
		host: String,
		token: String,
		isOAuth: Bool = false,
		refreshToken: String? = nil,
		expiresAt: Date? = nil
	) {
		self.host = host
		self.token = token
		self.isOAuth = isOAuth
		self.refreshToken = refreshToken
		self.expiresAt = expiresAt
	}

	var isValid: Bool {
		!token.isEmpty && !host.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
	}

	var needsTokenRefresh: Bool {
		guard isOAuth, refreshToken?.isNotEmpty == true else {
			return false
		}
		guard let expiresAt else {
			return true
		}
		return expiresAt < Date().addingTimeInterval(300)
	}
}

@MainActor
class InstanceManager {
	private static let userDefaults: UserDefaults =
		UserDefaults(suiteName: "group.de.schindlerfelix.GitLab") ?? .standard
	private static let instancesKey = "instances"
	private static let selectedKey = "selectedInstance"
	private static let watchSelectedKey = "watchSelectedInstance"

	static var instances: [GitLabInstance] {
		get {
			guard let data = userDefaults.data(forKey: instancesKey),
				let instances = try? JSONDecoder().decode([GitLabInstance].self, from: data)
			else {
				return []
			}
			return instances
		}
		set {
			if let data = try? JSONEncoder().encode(newValue) {
				userDefaults.set(data, forKey: instancesKey)
			}
		}
	}

	static var selectedId: String? {
		get {
			userDefaults.string(forKey: selectedKey)
		}
		set {
			userDefaults.set(newValue, forKey: selectedKey)
		}
	}

	static var watchSelectedId: String? {
		get {
			UserDefaults.standard.string(forKey: watchSelectedKey)
		}
		set {
			UserDefaults.standard.set(newValue, forKey: watchSelectedKey)
		}
	}

	static var selected: GitLabInstance? {
		guard let id = selectedId else { return nil }
		return instances.first { $0.id == id }
	}

	static func add(_ instance: GitLabInstance) {
		var current = instances
		current.removeAll { $0.id == instance.id }
		current.append(instance)
		instances = current
		selectedId = instance.id
	}

	static func remove(_ instance: GitLabInstance) {
		var current = instances
		current.removeAll { $0.id == instance.id }
		instances = current

		if selectedId == instance.id {
			selectedId = current.last?.id
		}
		if watchSelectedId == instance.id {
			watchSelectedId = current.last?.id
		}
	}

	static func update(_ instance: GitLabInstance) {
		var current = instances
		guard let index = current.firstIndex(where: { $0.id == instance.id }) else {
			add(instance)
			return
		}
		current[index] = instance
		instances = current
	}

	static func select(_ instance: GitLabInstance) {
		selectedId = instance.id
		watchSelectedId = instance.id
	}

	static func overwrite(instances: [GitLabInstance], selectedId: String?) {
		let valid = instances.filter { $0.isValid }
		self.instances = valid

		if let selectedId, valid.contains(where: { $0.id == selectedId }) {
			self.selectedId = selectedId
			watchSelectedId = selectedId
			return
		}

		let watchSelected = watchSelectedId
		if let watchSelected, valid.contains(where: { $0.id == watchSelected }) {
			self.selectedId = watchSelected
			return
		}

		let fallback = valid.last?.id
		self.selectedId = fallback
		watchSelectedId = fallback
	}
}

enum WatchAuthError: LocalizedError {
	case noInstance
	case sessionExpired
	case refreshFailed

	var errorDescription: String? {
		switch self {
		case .noInstance:
			return "No instance selected. Add an instance on iPhone first."
		case .sessionExpired:
			return "Session expired. Please open Tanuki on iPhone to log in again."
		case .refreshFailed:
			return "Token refresh failed. Please check your connection and try again."
		}
	}
}

private struct WatchOAuthToken: Decodable {
	let accessToken: String
	let refreshToken: String
	let createdAt: Int
	let expiresIn: Int

	var expiresAt: Date {
		Date(timeIntervalSince1970: TimeInterval(createdAt))
			.addingTimeInterval(TimeInterval(expiresIn))
	}
}

@MainActor
final class WatchAuth {
	static let clientID = "9ee458e1f3cca37c7d9c6651da1caa5d242ce9988e08471e7cba278cbe2eced2"
	static let redirectUri = "tanuki://oauth/callback"

	private static var refreshTask: Task<String, Error>?

	nonisolated static func isUnauthorized(_ error: Error) -> Bool {
		if let responseError = error as? ResponseCodeInterceptor.ResponseCodeError {
			return responseError.response.statusCode == 401
		}
		return false
	}

	static func ensureValidToken() async {
		guard let instance = InstanceManager.selected, instance.needsTokenRefresh else {
			return
		}
		do {
			_ = try await refreshAccessToken()
		} catch {
			if isUnrecoverable(error) {
				removeInstance(id: instance.id)
			}
		}
	}

	static func refreshAccessToken() async throws -> String {
		if let refreshTask {
			return try await refreshTask.value
		}

		guard let instance = InstanceManager.selected,
			instance.isOAuth,
			let refreshToken = instance.refreshToken,
			refreshToken.isNotEmpty
		else {
			throw WatchAuthError.sessionExpired
		}

		let instanceId = instance.id
		let host = instance.host
		let task = Task<String, Error> {
			try await performRefresh(host: host, refreshToken: refreshToken)
		}
		refreshTask = task

		do {
			let accessToken = try await task.value
			refreshTask = nil
			return accessToken
		} catch {
			refreshTask = nil
			throw error
		}
	}

	static func handleUnauthorized(instanceId: String) async -> String? {
		guard let current = InstanceManager.selected, current.id == instanceId else {
			return nil
		}
		guard current.isOAuth, current.refreshToken?.isNotEmpty == true else {
			removeInstance(id: instanceId)
			return nil
		}
		do {
			let token = try await refreshAccessToken()
			guard InstanceManager.selected?.id == instanceId else { return nil }
			return token
		} catch {
			if isUnrecoverable(error) {
				removeInstance(id: instanceId)
			}
			return nil
		}
	}

	private static func performRefresh(host: String, refreshToken: String) async throws -> String {
		var components = URLComponents()
		components.queryItems = [
			URLQueryItem(name: "client_id", value: clientID),
			URLQueryItem(name: "refresh_token", value: refreshToken),
			URLQueryItem(name: "grant_type", value: "refresh_token"),
			URLQueryItem(name: "redirect_uri", value: redirectUri),
		]
		guard let tokenURL = URL(string: "https://\(host)/oauth/token"),
			let body = components.percentEncodedQuery?.data(using: .utf8)
		else {
			throw WatchAuthError.sessionExpired
		}

		var request = URLRequest(url: tokenURL)
		request.httpMethod = "POST"
		request.setValue(
			"application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
		request.httpBody = body

		let (data, response) = try await URLSession.shared.data(for: request)
		guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
			let status = (response as? HTTPURLResponse)?.statusCode
			if status == 400 || status == 401 {
				throw WatchAuthError.sessionExpired
			}
			throw WatchAuthError.refreshFailed
		}

		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		let token = try decoder.decode(WatchOAuthToken.self, from: data)

		if InstanceManager.selected?.host == host {
			InstanceManager.update(
				GitLabInstance(
					host: host,
					token: token.accessToken,
					isOAuth: true,
					refreshToken: token.refreshToken,
					expiresAt: token.expiresAt
				)
			)
			Network.shared.resetApolloClient()
		}
		return token.accessToken
	}

	private static func removeInstance(id: String) {
		guard let instance = InstanceManager.instances.first(where: { $0.id == id }) else {
			return
		}
		InstanceManager.remove(instance)
		Network.shared.resetApolloClient()
	}

	nonisolated private static func isUnrecoverable(_ error: Error) -> Bool {
		if let authError = error as? WatchAuthError, case .sessionExpired = authError {
			return true
		}
		return false
	}
}

@MainActor
final class WatchSync: NSObject, WCSessionDelegate {
	static let shared = WatchSync()
	private let decoder = JSONDecoder()
	private var didActivate = false

	func activate() {
		guard WCSession.isSupported() else { return }
		let session = WCSession.default
		session.delegate = self
		session.activate()
	}

	func requestContextRefresh() {
		guard WCSession.isSupported() else { return }
		let session = WCSession.default
		if !didActivate {
			activate()
		}
		apply(session.receivedApplicationContext)
	}

	private func apply(_ context: [String: Any]) {
		let data = context["instances"] as? Data
		let selectedId = context["selectedId"] as? String
		apply(instancesData: data, selectedId: selectedId)
	}

	private func apply(instancesData: Data?, selectedId: String?) {
		guard let data = instancesData,
			let instances = try? decoder.decode([GitLabInstance].self, from: data)
		else {
			return
		}
		InstanceManager.overwrite(instances: instances, selectedId: selectedId)
		Network.shared.resetApolloClient()
	}

	nonisolated func session(
		_ session: WCSession,
		activationDidCompleteWith activationState: WCSessionActivationState,
		error: Error?
	) {
		Task { @MainActor in
			didActivate = activationState == .activated
			if didActivate {
				requestContextRefresh()
			}
		}
	}

	nonisolated func session(
		_ session: WCSession,
		didReceiveApplicationContext applicationContext: [String: Any]
	) {
		let instancesData = applicationContext["instances"] as? Data
		let selectedId = applicationContext["selectedId"] as? String
		Task { @MainActor in
			apply(instancesData: instancesData, selectedId: selectedId)
		}
	}
}

@MainActor
class API {
	/// GitLab host
	public static var host: String {
		sanitizedHost(InstanceManager.selected?.host) ?? "gitlab.com"
	}

	/// GitLab token
	public static var token: String {
		InstanceManager.selected?.token ?? ""
	}

	public static var currentInstance: GitLabInstance? {
		InstanceManager.selected
	}

	public static var url: URL {
		URL(string: "https://\(host)") ?? URL(string: "https://gitlab.com")!
	}

	public static var graphUrl: URL {
		URL(string: "https://\(host)/api/graphql")
			?? URL(string: "https://gitlab.com/api/graphql")!
	}

	private static func sanitizedHost(_ raw: String?) -> String? {
		guard var value = raw?.trimmingCharacters(in: .whitespacesAndNewlines),
			!value.isEmpty
		else {
			return nil
		}
		if let schemeRange = value.range(of: "://") {
			value = String(value[schemeRange.upperBound...])
		}
		if let slash = value.firstIndex(of: "/") {
			value = String(value[..<slash])
		}
		value = value.lowercased()
		guard !value.isEmpty, URL(string: "https://\(value)") != nil else {
			return nil
		}
		return value
	}
}

@MainActor
final class Network {
	static let shared = Network()

	private(set) var apollo: ApolloClient

	init() {
		self.apollo = Network.buildApolloClient()
	}

	func resetApolloClient() {
		self.apollo = Network.buildApolloClient()
	}

	private static func buildApolloClient() -> ApolloClient {
		let store = ApolloStore(cache: InMemoryNormalizedCache())

		let transport = RequestChainNetworkTransport(
			urlSession: URLSession.shared,
			interceptorProvider: NetworkInterceptorProvider(),
			store: store,
			endpointURL: API.graphUrl
		)

		return ApolloClient(networkTransport: transport, store: store)
	}
}

@MainActor
final class AuthorizationInterceptor: GraphQLInterceptor {
	func intercept<Request: GraphQLRequest>(
		request: Request,
		next: NextInterceptorFunction<Request>
	) async throws -> InterceptorResultStream<Request> {
		await WatchAuth.ensureValidToken()

		var req = request
		req.addHeader(name: "Authorization", value: "Bearer \(API.token)")
		let instanceId = API.currentInstance?.id

		let stream = await next(req)
		return await stream.mapErrors { error in
			guard WatchAuth.isUnauthorized(error), let instanceId else {
				throw error
			}
			_ = await WatchAuth.handleUnauthorized(instanceId: instanceId)
			throw error
		}
	}
}

final class NetworkInterceptorProvider: InterceptorProvider {
	nonisolated func graphQLInterceptors<Operation: GraphQLOperation>(for operation: Operation)
		-> [any GraphQLInterceptor]
	{
		return [
			AuthorizationInterceptor()
		]
	}
}
