//
//  API.swift
//  Tanuki (GitLab)
//
//  Created by Felix Schindler on 30.10.21.
//  Rewritten by Felix Schindler on 07.03.24.
//

import Alamofire
import Foundation
import OSLog
import SwiftUI

#if canImport(WatchConnectivity)
	import WatchConnectivity
#endif

enum DateError: String, Error {
	case invalidDate
}

enum ContentType: String {
	case json = "application/json"
	case formUrlEncoded = "application/x-www-form-urlencoded"
}

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
	private static let userDefaults = UserDefaults(suiteName: "group.de.schindlerfelix.GitLab")!
	private static let legacyUserDefaults = UserDefaults(suiteName: "de.schindlerfelix.GitLab")
	private static let instancesKey = "instances"
	private static let selectedKey = "selectedInstance"
	private static let legacyHostKey = "domain"
	private static let legacyTokenKey = "token"
	private static let migrationDoneKey = "migration_done"

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

	static var selected: GitLabInstance? {
		guard let id = selectedId else { return nil }
		return instances.first { $0.id == id }
	}

	static func migrate() {
		removeInvalid()
		guard !userDefaults.bool(forKey: migrationDoneKey) else { return }

		let legacyStore = legacyUserDefaults
		let oldHost =
			legacyStore?.string(forKey: legacyHostKey)
			?? userDefaults.string(forKey: legacyHostKey)
		let oldToken =
			(legacyStore?.string(forKey: legacyTokenKey)
			?? userDefaults.string(forKey: legacyTokenKey))?.trimmingCharacters(in: .whitespacesAndNewlines)

		// Only a stored token is worth migrating. Without one this is a fresh
		// install; previously the host defaulted to "gitlab.com", so the guard was
		// always true and an empty-token instance suppressed the login screen.
		guard let oldToken, oldToken.isNotEmpty else {
			userDefaults.set(true, forKey: migrationDoneKey)
			return
		}
		let host = oldHost?.isNotEmpty == true ? oldHost! : "gitlab.com"

		add(
			GitLabInstance(
				host: host,
				token: oldToken,
				isOAuth: host == "gitlab.com"
			)
		)

		userDefaults.removeObject(forKey: legacyHostKey)
		userDefaults.removeObject(forKey: legacyTokenKey)
		legacyStore?.removeObject(forKey: legacyHostKey)
		legacyStore?.removeObject(forKey: legacyTokenKey)
		userDefaults.set(true, forKey: migrationDoneKey)
		WatchSync.shared.pushInstances()
	}

	static func add(_ instance: GitLabInstance) {
		var current = instances
		current.removeAll { $0.id == instance.id }
		current.append(instance)
		instances = current
		selectedId = instance.id
		WatchSync.shared.pushInstances()
	}

	static func remove(_ instance: GitLabInstance) {
		var current = instances
		current.removeAll { $0.id == instance.id }
		instances = current

		if selectedId == instance.id {
			selectedId = current.last?.id
		}
		WatchSync.shared.pushInstances()
	}

	static func select(_ instance: GitLabInstance) {
		selectedId = instance.id
		WatchSync.shared.pushInstances()
	}

	static func update(_ instance: GitLabInstance) {
		var current = instances
		guard let index = current.firstIndex(where: { $0.id == instance.id }) else {
			add(instance)
			return
		}
		current[index] = instance
		instances = current
		WatchSync.shared.pushInstances()
	}

	/// Drops instances without a token (the phantom the old `migrate()` created on
	/// fresh installs) and points the selection at a valid one. Runs at launch
	/// before any network client is built, so there are no caches to reset.
	static func removeInvalid() {
		let current = instances
		let valid = current.filter { $0.token.isNotEmpty }
		let selection = valid.contains { $0.id == selectedId } ? selectedId : valid.last?.id
		guard valid.count != current.count || selection != selectedId else { return }
		instances = valid
		selectedId = selection
		WatchSync.shared.pushInstances()
	}
}

@MainActor
final class WatchSync: NSObject, WCSessionDelegate {
	static let shared = WatchSync()
	private let encoder = JSONEncoder()
	private var didActivate = false

	func activate() {
		guard WCSession.isSupported() else { return }
		let session = WCSession.default
		session.delegate = self
		session.activate()
	}

	func pushInstances() {
		guard WCSession.isSupported() else { return }
		let session = WCSession.default
		if !didActivate {
			activate()
		}

		guard let data = try? encoder.encode(InstanceManager.instances) else { return }
		var context: [String: Any] = [
			"instances": data
		]
		if let selectedId = InstanceManager.selectedId {
			context["selectedId"] = selectedId
		}

		try? session.updateApplicationContext(context)
	}

	nonisolated func session(
		_ session: WCSession,
		activationDidCompleteWith activationState: WCSessionActivationState,
		error: Error?
	) {
		Task { @MainActor in
			didActivate = activationState == .activated
			if didActivate {
				pushInstances()
			}
		}
	}

	nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}

	nonisolated func sessionDidDeactivate(_ session: WCSession) {
		session.activate()
	}
}

enum APIError: LocalizedError {
	case http(status: Int, message: String?)
	case emptyResponse

	var errorDescription: String? {
		switch self {
		case .http(let status, let message):
			let detail =
				message.flatMap { $0.isEmpty ? nil : $0 }
				?? HTTPURLResponse.localizedString(forStatusCode: status)
			return "HTTP \(status): \(detail)"
		case .emptyResponse:
			return "The server returned an empty response."
		}
	}

	var isUnauthorized: Bool {
		if case .http(let status, _) = self {
			return status == 401
		}
		return false
	}
}

@MainActor
class API {
	/// API endpoint (including version)
	public static var base: String = "api/v4"

	private static let encoder = JSONEncoder()
	private static let decoder = JSONDecoder()
	private static let session: Session = .default

	public static var host: String {
		InstanceManager.selected?.host ?? "gitlab.com"
	}

	public static var token: String {
		InstanceManager.selected?.token ?? ""
	}

	public static var isOAuth: Bool {
		InstanceManager.selected?.isOAuth ?? false
	}

	public static var currentInstance: GitLabInstance? {
		InstanceManager.selected
	}

	public static var url: URL {
		URL(string: "https://\(host)")!
	}

	public static var graphUrl: URL {
		URL(string: "https://\(host)/api/graphql")!
	}

	/// This is only `public` because it's used by `FileLoader` and `FeedbackView`
	public static func raw(
		method: HTTPMethod,
		endpoint: String,
		resource: String? = nil,
		suffix: String? = nil,
		query: [String: String] = [:],
		body: (any Encodable)? = nil,
		contentType: ContentType = .json,
		auth: Bool = true,
		useBase: Bool = true,
		host: String? = nil
	) async throws -> AFDataResponse<Data> {
		if auth {
			await Auth.ensureValidToken()
		}
		let instanceId = auth ? InstanceManager.selected?.id : nil

		var response = try await API.executeRaw(
			method: method,
			endpoint: endpoint,
			resource: resource,
			suffix: suffix,
			query: query,
			body: body,
			contentType: contentType,
			auth: auth,
			useBase: useBase,
			host: host
		)

		if response.response?.statusCode == 401, let instanceId,
			await Auth.handleUnauthorized(instanceId: instanceId) != nil
		{
			response = try await API.executeRaw(
				method: method,
				endpoint: endpoint,
				resource: resource,
				suffix: suffix,
				query: query,
				body: body,
				contentType: contentType,
				auth: auth,
				useBase: useBase,
				host: host
			)
		}

		if let error = response.error {
			logger.error("✗ \(method.rawValue) \(endpoint) — \(error.localizedDescription)")
			throw error
		}

		if let status = response.response?.statusCode, !(200..<300).contains(status) {
			let message = API.errorMessage(from: response.data)
			logger.error("✗ \(status) \(method.rawValue) \(endpoint) — \(message ?? "no error message")")
			throw APIError.http(status: status, message: message)
		}

		if let status = response.response?.statusCode {
			logger.info("← \(status) \(method.rawValue) \(endpoint) (\(response.data?.count ?? 0) bytes)")
		}

		return response
	}

	private static func executeRaw(
		method: HTTPMethod,
		endpoint: String,
		resource: String? = nil,
		suffix: String? = nil,
		query: [String: String] = [:],
		body: (any Encodable)? = nil,
		contentType: ContentType = .json,
		auth: Bool = true,
		useBase: Bool = true,
		host: String? = nil
	) async throws -> AFDataResponse<Data> {
		let (url, headers) = API.urlAndHeaders(
			method: method,
			endpoint: endpoint,
			resource: resource,
			suffix: suffix,
			query: query,
			contentType: contentType,
			auth: auth,
			useBase: useBase,
			host: host
		)

		var parameters: Parameters?
		if let body {
			parameters = try JSONSerialization.jsonObject(with: encoder.encode(body)) as? Parameters
		}

		let encoding: ParameterEncoding =
			(contentType == .json) ? JSONEncoding.default : URLEncoding.default

		let response = await session.request(
			url,
			method: method,
			parameters: parameters,
			encoding: encoding,
			headers: headers
		).serializingData().response

		return response
	}

	/// Streams a file straight to disk instead of buffering it in memory (see `FileLoader`).
	///
	/// Unlike `raw`, a rejected token is not retried — `Auth.ensureValidToken()` runs upfront.
	public static func download(
		to destination: @escaping DownloadRequest.Destination,
		method: HTTPMethod,
		endpoint: String,
		resource: String? = nil,
		suffix: String? = nil,
		query: [String: String] = [:],
		auth: Bool = true,
		useBase: Bool = true,
		host: String? = nil,
		onProgress: (@MainActor @Sendable (_ received: Int64, _ total: Int64) -> Void)? = nil
	) async throws -> URL {
		if auth {
			await Auth.ensureValidToken()
		}

		let (url, headers) = API.urlAndHeaders(
			method: method,
			endpoint: endpoint,
			resource: resource,
			suffix: suffix,
			query: query,
			contentType: .json,
			auth: auth,
			useBase: useBase,
			host: host
		)

		let request = session.download(url, method: method, headers: headers, to: destination)

		if let onProgress {
			request.downloadProgress { progress in
				MainActor.assumeIsolated {
					onProgress(progress.completedUnitCount, progress.totalUnitCount)
				}
			}
		}

		let response = await request.serializingDownloadedFileURL().response

		if let error = response.error {
			logger.error("✗ \(method.rawValue) \(endpoint) — \(error.localizedDescription)")
			throw error
		}

		if let status = response.response?.statusCode, !(200..<300).contains(status) {
			logger.error("✗ \(status) \(method.rawValue) \(endpoint) — no error message")
			throw APIError.http(status: status, message: nil)
		}

		guard let fileURL = response.fileURL else {
			throw APIError.emptyResponse
		}

		logger.info("← \(method.rawValue) \(endpoint) (\(fileURL.fileSize()) bytes)")

		return fileURL
	}

	private static func urlAndHeaders(
		method: HTTPMethod,
		endpoint: String,
		resource: String?,
		suffix: String?,
		query: [String: String],
		contentType: ContentType,
		auth: Bool,
		useBase: Bool,
		host: String?
	) -> (url: String, headers: HTTPHeaders) {
		let targetHost = host ?? API.host

		var path = useBase ? [base, endpoint] : [endpoint]
		if let resource {
			path.append(API.encodePathComponent(resource))
		}
		if let suffix {
			// Callers pass "/raw"; without trimming, joining yields "//raw" and a 308.
			path.append(suffix.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
		}

		var url = "https://\(targetHost)/" + path.joined(separator: "/")
		if let queryString = API.queryString(query) {
			url += "?" + queryString
		}

		var headers: HTTPHeaders = [.contentType(contentType.rawValue)]
		if auth && token.isNotEmpty {
			headers.add(.authorization(bearerToken: token))
		}

		logger.debug("→ \(method.rawValue) \(url) [\(API.redacted(headers))]")

		return (url, headers)
	}

	private static func encodePathComponent(_ value: String) -> String {
		var allowed = CharacterSet.urlPathAllowed
		allowed.remove(charactersIn: "/")
		return value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
	}

	private static func queryString(_ query: [String: String]) -> String? {
		guard !query.isEmpty else { return nil }

		var components = URLComponents()
		components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
		return components.percentEncodedQuery
	}

	private static func redacted(_ headers: HTTPHeaders) -> String {
		headers.map { header in
			header.name.lowercased() == "authorization"
				? "\(header.name): <redacted>"
				: "\(header.name): \(header.value)"
		}.joined(separator: ", ")
	}

	private static func errorMessage(from data: Data?) -> String? {
		guard let data,
			let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
		else {
			return nil
		}

		if let message = object["message"] as? String {
			return message
		}
		if let error = object["error"] as? String {
			return error
		}

		return nil
	}

	public static func req<T: Codable>(
		type: T.Type,
		method: HTTPMethod,
		endpoint: String,
		resource: String? = nil,
		suffix: String? = nil,
		query: [String: String] = [:],
		body: (any Encodable)? = nil,
		contentType: ContentType = .json,
		auth: Bool = true,
		useBase: Bool = true,
		host: String? = nil
	) async throws -> T {
		let response = try await API.raw(
			method: method,
			endpoint: endpoint,
			resource: resource,
			suffix: suffix,
			query: query,
			body: body,
			contentType: contentType,
			auth: auth,
			useBase: useBase,
			host: host
		)

		guard let data = response.data else {
			logger.error("✗ \(endpoint): empty response body")
			throw APIError.emptyResponse
		}

		decoder.keyDecodingStrategy = .convertFromSnakeCase

		decoder.dateDecodingStrategy = .custom({ decoder -> Date in
			let formatter = ISO8601DateFormatter()
			formatter.formatOptions = [
				.withInternetDateTime, .withFractionalSeconds,
			]

			let dateStr = try decoder.singleValueContainer().decode(String.self)

			if let date = formatter.date(from: dateStr) {
				return date
			}

			throw DateError.invalidDate
		})

		do {
			return try decoder.decode(T.self, from: data)
		} catch let error {
			logger.error(
				"✗ \(endpoint): decoding \(String(describing: T.self)) failed — \(error.localizedDescription)"
			)
			throw error
		}
	}

	public static func get<T: Codable>(
		type: T.Type,
		endpoint: String,
		query: [String: String] = [:],
		useBase: Bool = true
	) async throws -> T {
		try await API.req(
			type: type,
			method: .get,
			endpoint: endpoint,
			query: query,
			useBase: useBase
		)
	}

	public static func delete(
		endpoint: String,
		query: [String: String] = [:]
	) async throws {
		_ = try await API.raw(
			method: .delete,
			endpoint: endpoint,
			query: query,
			auth: true
		)
	}
}
