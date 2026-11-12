//
//  Network.swift
//  Tanuki
//
//  Created by Felix Schindler on 26.02.24.
//

import Apollo
import ApolloAPI
import ApolloSQLite
import Foundation

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
		let documentsPath = NSSearchPathForDirectoriesInDomains(
			.documentDirectory,
			.userDomainMask,
			true
		).first!
		let documentsURL = URL(fileURLWithPath: documentsPath)
		let sqliteFileURL = documentsURL.appendingPathComponent("tanuki_graphql_cache.sqlite")

		// Cache on disk; Fall back to in-memory cache if unavailable
		var cache: NormalizedCache
		do {
			cache = try SQLiteNormalizedCache(fileURL: sqliteFileURL)
		} catch let error {
			print("Using in-memory cache", error)
			cache = InMemoryNormalizedCache()
		}

		let store = ApolloStore(cache: cache)

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
final class AuthorizationInterceptor: HTTPInterceptor {
	func intercept(
		request: URLRequest,
		next: NextHTTPInterceptorFunction
	) async throws -> HTTPResponse {
		await Auth.ensureValidToken()

		var request = request
		request.setValue("Bearer \(API.token)", forHTTPHeaderField: "Authorization")

		let response = try await next(request)
		guard response.response.statusCode == 401,
			let instanceId = API.currentInstance?.id,
			let token = await Auth.handleUnauthorized(instanceId: instanceId)
		else {
			return response
		}

		request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		return try await next(request)
	}
}

final class NetworkInterceptorProvider: InterceptorProvider {
	nonisolated func graphQLInterceptors<Operation: GraphQLOperation>(for operation: Operation)
		-> [any GraphQLInterceptor]
	{
		[]
	}

	nonisolated func httpInterceptors<Operation: GraphQLOperation>(for operation: Operation)
		-> [any HTTPInterceptor]
	{
		[
			AuthorizationInterceptor(),
			ResponseCodeInterceptor(),
		]
	}
}
