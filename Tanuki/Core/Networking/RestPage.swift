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
