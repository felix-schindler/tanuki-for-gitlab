//
//  LoadableList.swift
//  Tanuki
//

import SwiftUI

struct LoadableList<Item, ItemID: Hashable, Row: View>: View {
	let state: Loadable<[Item]>
	let hasMore: Bool
	let onLoadMore: () async -> Void
	let onRefresh: () async -> Void
	let id: KeyPath<Item, ItemID>
	let row: (Item) -> Row

	private let emptyMessage: String
	private let emptySystemImage: String
	private let emptyDescription: String?
	private let loadingMessage: String
	private let loadingSystemImage: String

	init(
		_ state: Loadable<[Item]>,
		id: KeyPath<Item, ItemID>,
		hasMore: Bool = false,
		emptyMessage: String,
		emptySystemImage: String,
		emptyDescription: String? = nil,
		loadingMessage: String,
		loadingSystemImage: String,
		onLoadMore: @escaping () async -> Void = {},
		onRefresh: @escaping () async -> Void,
		@ViewBuilder row: @escaping (Item) -> Row
	) {
		self.state = state
		self.id = id
		self.hasMore = hasMore
		self.emptyMessage = emptyMessage
		self.emptySystemImage = emptySystemImage
		self.emptyDescription = emptyDescription
		self.loadingMessage = loadingMessage
		self.loadingSystemImage = loadingSystemImage
		self.onLoadMore = onLoadMore
		self.onRefresh = onRefresh
		self.row = row
	}

	var body: some View {
		List {
			if state.isInitialLoading {
				LoadingView(loadingMessage, systemImage: loadingSystemImage)
			} else if state.isColdFailure, let error = state.error {
				FailedView(error)
			} else if let items = state.value {
				if items.isEmpty {
					NoContentView(emptyMessage, systemImage: emptySystemImage, description: emptyDescription)
				} else {
					ForEach(items, id: id) { item in
						row(item)
					}

					if hasMore {
						HStack {
							Spacer()
							ProgressView()
							Spacer()
						}.task {
							await onLoadMore()
						}
					}
				}
			}
		}.refreshable {
			await onRefresh()
		}
	}
}
