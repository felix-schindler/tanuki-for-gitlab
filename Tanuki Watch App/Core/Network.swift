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
	private static let hostsKey = "instanceHosts"
	private static let legacyInstancesKey = "instances"
	private static let selectedKey = "selectedInstance"
	private static let watchSelectedKey = "watchSelectedInstance"

	static var instances: [GitLabInstance] {
		get {
			let hosts = userDefaults.stringArray(forKey: hostsKey) ?? []
			let keychain: [GitLabInstance] = hosts.compactMap { host in
				guard let data = Keychain.data(for: host) else {
					return nil
				}
				return try? JSONDecoder().decode(GitLabInstance.self, from: data)
			}
			// Pre-Keychain install, or a Keychain that cannot be read: keep working
			// instead of logging the user out.
			if keychain.isEmpty, let legacy = legacyInstances() {
				return legacy
			}
			return keychain
		}
		set {
			let ids = Set(newValue.map(\.id))
			let oldIds = userDefaults.stringArray(forKey: hostsKey) ?? []
			for id in oldIds where !ids.contains(id) {
				// Only prune readable items: a locked-device read failure must not delete credentials.
				if Keychain.data(for: id) != nil {
					Keychain.remove(id)
				}
			}
			for instance in newValue {
				if let data = try? JSONEncoder().encode(instance) {
					Keychain.set(data, for: instance.id)
				}
			}
			userDefaults.set(newValue.map(\.id), forKey: hostsKey)
		}
	}

	static func migrate() {
		guard let legacy = legacyInstances(), !legacy.isEmpty else {
			return
		}
		instances = legacy
		// Drop the clear-text copy only once the Keychain write is proven, so a
		// failure cannot log the user out on upgrade.
		guard legacy.allSatisfy({ Keychain.data(for: $0.id) != nil }) else {
			return
		}
		userDefaults.removeObject(forKey: legacyInstancesKey)
	}

	private static func legacyInstances() -> [GitLabInstance]? {
		guard let data = userDefaults.data(forKey: legacyInstancesKey),
			let legacy = try? JSONDecoder().decode([GitLabInstance].self, from: data)
		else {
			return nil
		}
		return legacy
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

@MainActor
final class WatchAuth {
	/// One request in flight at a time, so several callers don't ask the phone twice.
	private static var tokenTask: Task<String, Error>?

	nonisolated static func isUnauthorized(_ error: Error) -> Bool {
		if let responseError = error as? ResponseCodeInterceptor.ResponseCodeError {
			return responseError.response.statusCode == 401
		}
		return false
	}

	/// Renews the token on the iPhone. This process deliberately never calls
	/// `oauth/token`: GitLab invalidates the previous refresh token on every
	/// refresh, so two independent refreshes would log both devices out.
	static func ensureValidToken() async {
		guard let instance = InstanceManager.selected, instance.needsTokenRefresh else {
			return
		}
		_ = try? await requestAccessToken()
	}

	static func handleUnauthorized(instanceId: String) async -> String? {
		guard let current = InstanceManager.selected, current.id == instanceId else {
			return nil
		}
		guard current.isOAuth else {
			// A personal access token can't be renewed here. Keep the account and
			// let the iPhone remove it when it decides the session is gone.
			return nil
		}
		let token = try? await requestAccessToken()
		guard InstanceManager.selected?.id == instanceId else { return nil }
		return token
	}

	static func requestAccessToken() async throws -> String {
		if let tokenTask {
			return try await tokenTask.value
		}
		let task = Task<String, Error> {
			try await fetchTokenFromPhone()
		}
		tokenTask = task

		do {
			let token = try await task.value
			tokenTask = nil
			return token
		} catch {
			tokenTask = nil
			throw error
		}
	}

	private static func fetchTokenFromPhone() async throws -> String {
		let session = WCSession.default
		if session.activationState != .activated {
			WatchSync.shared.activate()
		}
		guard WCSession.isSupported(), session.isReachable else {
			throw WatchAuthError.sessionExpired
		}

		let payload: (instances: Data?, selectedId: String?) = try await withCheckedThrowingContinuation {
			continuation in
			session.sendMessage(
				["requestToken": true],
				replyHandler: { reply in
					continuation.resume(
						returning: (
							instances: reply["instances"] as? Data,
							selectedId: reply["selectedId"] as? String
						)
					)
				},
				errorHandler: { _ in
					continuation.resume(throwing: WatchAuthError.sessionExpired)
				}
			)
		}

		guard let data = payload.instances,
			let instances = try? JSONDecoder().decode([GitLabInstance].self, from: data)
		else {
			throw WatchAuthError.refreshFailed
		}
		InstanceManager.overwrite(instances: instances, selectedId: payload.selectedId)
		Network.shared.resetApolloClient()

		guard let token = InstanceManager.selected?.token, token.isNotEmpty else {
			throw WatchAuthError.sessionExpired
		}
		return token
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
		if let fragment = value.firstIndex(of: "#") {
			value = String(value[..<fragment])
		}
		if let query = value.firstIndex(of: "?") {
			value = String(value[..<query])
		}
		// Keep the port and base path: a self-hosted instance may live on either.
		value = value.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
		guard !value.isEmpty,
			let url = URL(string: "https://\(value)"),
			url.host()?.isNotEmpty == true
		else {
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
