//
//  RestPage.swift
//  Tanuki
//

import Foundation

/// Offset paging for the few REST lists that need it.
struct RestPage {
	static let size = 100

	private(set) var page = 1
	private(set) var hasMore = true

	mutating func reset() {
		page = 1
		hasMore = true
	}

	mutating func advance(_ count: Int) {
		hasMore = count == Self.size
		page += 1
	}

	/// Query parameters for the current page. Call `advance` after a successful request.
	var query: [String: String] {
		["per_page": String(Self.size), "page": String(page)]
	}
}

extension API {
	/// Every page of a REST list, for pickers that need the whole set up front.
	static func allPages<T: Codable>(
		_ type: [T].Type,
		endpoint: String,
		query: [String: String] = [:]
	) async throws -> [T] {
		var items: [T] = []
		var page = RestPage()
		// shortcut: caps at 5000 items, raise if a picker ever needs more
		while page.page <= 50 {
			let batch = try await API.get(
				type: [T].self,
				endpoint: endpoint,
				query: query.merging(page.query) { _, new in new }
			)
			items += batch
			page.advance(batch.count)
			if !page.hasMore { break }
		}
		return items
	}
}
