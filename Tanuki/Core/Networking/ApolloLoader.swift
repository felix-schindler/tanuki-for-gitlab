//
//  ApolloLoader.swift
//  Tanuki
//

import Apollo
import ApolloAPI
import Observation

/// Loads one single-response GraphQL operation: cache first, then network, with pull-to-refresh.
/// Held in `@State`; views read `state` directly.
@MainActor
@Observable
final class ApolloLoader<Query: GraphQLQuery, Value>
where Query.ResponseFormat == SingleResponseFormat {
	private(set) var state = Loadable<Value>()
	private let extract: (Query.Data) -> Value?

	/// Bumped by every load/refresh so a slow stream cannot overwrite a newer result.
	private var generation = 0

	init(extract: @escaping (Query.Data) -> Value?) {
		self.extract = extract
	}

	/// Paint the cache, then replace it with the network result.
	func load(_ query: Query) async {
		let current = begin()
		do {
			for try await response in try Network.shared.apollo.fetch(
				query: query, cachePolicy: .cacheAndNetwork)
			{
				guard current == generation, !Task.isCancelled else { return }
				apply(response)
			}
		} catch {
			guard current == generation, !Task.isCancelled else { return }
			fail(error)
		}
		finish(current)
	}

	/// Pull-to-refresh: network only, never replaces good data with a failure.
	func reload(_ query: Query, notify: Bool = true) async {
		let current = begin()
		do {
			let response = try await Network.shared.apollo.fetch(
				query: query, cachePolicy: .networkOnly)
			guard current == generation, !Task.isCancelled else { return }
			apply(response)
			if notify {
				Notify.status(.success)
			}
		} catch {
			guard current == generation, !Task.isCancelled else { return }
			fail(error)
		}
		finish(current)
	}

	private func begin() -> Int {
		generation += 1
		state.isLoading = true
		return generation
	}

	private func finish(_ current: Int) {
		guard current == generation, !Task.isCancelled else { return }
		if state.value == nil, state.error == nil {
			state.error = LoadableError.empty
		}
		state.isLoading = false
	}

	private func apply(_ response: GraphQLResponse<Query>) {
		// Partial data is valid: report the errors but keep whatever arrived.
		if let value = response.data.flatMap(extract) {
			state.value = value
			state.error = nil
		}
		for error in response.errors ?? [] {
			Notify.status(.error, error.localizedDescription)
		}
		state.isLoading = false
	}

	private func fail(_ error: Error) {
		state.error = error
		state.isLoading = false
		Notify.status(.error)
	}
}
