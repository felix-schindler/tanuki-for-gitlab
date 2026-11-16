//
//  Loadable.swift
//  Tanuki
//

import Foundation

enum LoadableError: LocalizedError {
	case empty

	var errorDescription: String? {
		"The server returned no data."
	}
}

/// One state for every screen that loads data.
struct Loadable<Value> {
	var value: Value?
	var error: Error?
	var isLoading = false
	var isLoadingMore = false

	var isInitialLoading: Bool { value == nil && isLoading }
	var isColdFailure: Bool { value == nil && error != nil }
	var isRefreshing: Bool { value != nil && isLoading }
}
