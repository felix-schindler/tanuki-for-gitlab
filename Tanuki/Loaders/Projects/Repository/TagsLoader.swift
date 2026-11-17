//
//  TagsView.swift
//  GitLab
//
//  Created by Felix Schindler on 05.05.23.
//

import SwiftUI
import TanukiShared

struct Tag: Codable {
	let name: String
	let message: String  // Empty string if not set
	let target: String
	let commit: Commit
	let protected: Bool
}

struct TagsLoader: View {
	private let projectId: Int

	@State
	private var state = Loadable<[Tag]>()

	@State
	private var pager = RestPage()

	init(_ projectId: Int) {
		self.projectId = projectId
	}

	private func load(reset: Bool) async {
		if reset {
			pager.reset()
			state.isLoading = true
		} else {
			state.isLoadingMore = true
		}

		defer {
			state.isLoading = false
			state.isLoadingMore = false
		}

		do {
			let tags = try await API.get(
				type: [Tag].self,
				endpoint: "projects/\(projectId)/repository/tags",
				query: pager.query
			)

			if Task.isCancelled { return }
			state.value = reset ? tags : (state.value ?? []) + tags
			state.error = nil
			pager.advance(tags.count)
		} catch {
			if Task.isCancelled { return }
			state.error = error
			Notify.status(.error)
		}
	}

	private func loadMore() async {
		guard pager.hasMore, !state.isLoading, !state.isLoadingMore else { return }
		await load(reset: false)
	}

	public var body: some View {
		LoadableList(
			state,
			id: \.name,
			hasMore: pager.hasMore,
			emptyMessage: "You'll see your tags after you pushed them",
			emptySystemImage: Icons.code.rawValue,
			loadingMessage: "Loading Tags",
			loadingSystemImage: Icons.code.rawValue,
			onLoadMore: { await loadMore() },
			onRefresh: { await load(reset: true) },
			row: { tag in
				VStack(alignment: .leading) {
					Text(tag.name.emojized())
						.fontWeight(.medium)

					if tag.message.isNotEmpty {
						InlineMarkdown(tag.message)
					}

					ScrollView(.horizontal) {
						HStack {
							PillView(tag.commit.shortId)
								.font(.system(.footnote, design: .monospaced))
							PillView(tag.commit.authoredDate.toString(), icon: Icons.clock.rawValue)
						}
					}.font(.footnote)
					InlineMarkdown(tag.commit.title.emojized())
						.font(.footnote)
				}
			}
		).task {
			await load(reset: true)
		}.toolbar {
			NavigationLink(destination: NewTagView(projectId: projectId)) {
				Label("New tag", systemImage: "plus")
			}.tint(.accentColor)
		}.navigationTitle("Tags")
	}
}

#Preview {
	NavigationStack {
		TagsLoader(33_025_310)
	}
}
