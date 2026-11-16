//
//  PagedQuery.swift
//  Tanuki
//

import Apollo
import ApolloAPI
import ApolloPagination
import Combine
import Observation

/// One cursor-paged GraphQL connection: cache first, network refresh, load more.
/// Held in `@State`; views read `state` and `hasMore`.
@MainActor
@Observable
final class PagedQuery<Query: GraphQLQuery, Item>
where Query.ResponseFormat == SingleResponseFormat {
	/// Apollo's generated interface types are immutable value types, but not marked `Sendable`.
	struct Page: @unchecked Sendable {
		let items: [Item]
		let errors: [String]
		let firstPage: Query.Data?
	}

	private(set) var state = Loadable<[Item]>()
	private(set) var hasMore = false
	/// Data of the first page, for screens that also need envelope fields (counts, flags).
	private(set) var firstPage: Query.Data?

	private let extract: @Sendable (Query.Data) -> [Item]
	private let key: @Sendable (Item) -> String?
	private let hasNext: @Sendable (Query.Data) -> Bool
	private let endCursor: @Sendable (Query.Data) -> String?

	private var pager: GraphQLQueryPager<Page>?
	private var subscription: AnyCancellable?
	private var generation = 0
	private var notifyNextEmission = false
	private var currentQuery: Query?

	/// - Parameters:
	///   - extract: the page's nodes.
	///   - key: a stable identity per item, used to drop duplicates between pages.
	///   - hasNext: the connection's `pageInfo.hasNextPage`.
	///   - endCursor: the connection's `pageInfo.endCursor`.
	init(
		extract: @escaping @Sendable (Query.Data) -> [Item],
		key: @escaping @Sendable (Item) -> String?,
		hasNext: @escaping @Sendable (Query.Data) -> Bool,
		endCursor: @escaping @Sendable (Query.Data) -> String?
	) {
		self.extract = extract
		self.key = key
		self.hasNext = hasNext
		self.endCursor = endCursor
	}

	/// Starts a fresh pager: a filter change never mixes pages from two queries.
	func start(_ query: Query, setCursor: @escaping @Sendable (inout Query, String) -> Void) async {
		generation += 1
		let current = generation
		await pager?.reset()
		subscription?.cancel()

		// Keep the old rows while the same query reloads; a filter change must not mix results.
		if query != currentQuery {
			state = Loadable()
			firstPage = nil
		}
		currentQuery = query
		state.isLoading = true
		hasMore = false
		notifyNextEmission = false

		let extract = self.extract
		let key = self.key
		let hasNext = self.hasNext
		let endCursor = self.endCursor
		let pager = GraphQLQueryPager<Page>(
			client: Network.shared.apollo,
			initialQuery: query,
			extractPageInfo: { (page: PageExtractionData<Query, Query, PaginationOutput<Query, Query>?>) in
				switch page {
				case .initial(let data, _), .paginated(let data, _):
					CursorBasedPagination.Forward(hasNext: hasNext(data), endCursor: endCursor(data))
				}
			},
			pageResolver: { (info: CursorBasedPagination.Forward, direction: PaginationDirection) -> Query? in
				guard direction == .next, let endCursor = info.endCursor else { return nil }
				var next = query
				setCursor(&next, endCursor)
				return next
			},
			transform: { output in
				var items: [Item] = []
				var seen = Set<String>()
				for data in output.allData {
					for item in extract(data) {
						guard let id = key(item) else {
							items.append(item)
							continue
						}
						if seen.insert(id).inserted {
							items.append(item)
						}
					}
				}
				return Page(
					items: items,
					errors: output.lastUpdatedPage.errors?.compactMap(\.message) ?? [],
					firstPage: output.initialPage?.data
				)
			}
		)
		self.pager = pager
		subscription = pager.sink { [weak self] result in
			Task { @MainActor [weak self] in
				self?.apply(result, generation: current)
			}
		}
		await pager.fetch()
	}

	/// Pull-to-refresh: network only, keeps the list when it fails.
	func refresh(notify: Bool = true) async {
		guard let pager else { return }
		state.isLoading = true
		notifyNextEmission = notify
		await pager.refetch()
	}

	func loadMore() async {
		guard let pager, !state.isLoadingMore, await pager.canLoadNext else { return }
		state.isLoadingMore = true
		do {
			try await pager.loadNext()
		} catch {
			state.isLoadingMore = false
			if !(error is PaginationError), !(error is CancellationError) {
				Notify.status(.error)
			}
		}
	}

	private func apply(_ result: Result<Page, Error>, generation: Int) {
		guard generation == self.generation else { return }
		state.isLoading = false
		state.isLoadingMore = false

		switch result {
		case .success(let page):
			state.value = page.items
			state.error = nil
			firstPage = page.firstPage
			for message in page.errors {
				Notify.status(.error, message)
			}
			if notifyNextEmission {
				notifyNextEmission = false
				Notify.status(.success)
			}
		case .failure(let error):
			state.error = error
			notifyNextEmission = false
			Notify.status(.error)
		}

		guard let pager else { return }
		Task { @MainActor [weak self] in
			guard self?.pager === pager else { return }
			self?.hasMore = await pager.canLoadNext
		}
	}
}
