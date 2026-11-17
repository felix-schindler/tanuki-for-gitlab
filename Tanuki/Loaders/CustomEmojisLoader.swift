//
//  CustomEmojiLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 05.03.24.
//

import GitLabAPI
import SwiftUI
import TanukiShared

struct CustomEmojisLoader: View {
	private var fullPath: String

	@State
	private var pager = PagedQuery<GroupCustomEmojiQuery, GroupCustomEmojiQuery.Data.Group.CustomEmoji.Node>(
		extract: { ($0.group?.customEmoji?.nodes ?? []).compactMap { $0 } },
		key: { $0.id },
		hasNext: { $0.group?.customEmoji?.pageInfo.hasNextPage ?? false },
		endCursor: { $0.group?.customEmoji?.pageInfo.endCursor }
	)

	init(fullPath: String) {
		self.fullPath = fullPath
	}

	private func query(after: GraphQLNullable<String> = .none) -> GroupCustomEmojiQuery {
		GroupCustomEmojiQuery(first: 50, after: after, fullPath: fullPath)
	}

	public var body: some View {
		LoadableList(
			pager.state,
			hasMore: pager.hasMore,
			emptyMessage: "There are no custom emojis",
			emptySystemImage: "face.smiling",
			loadingMessage: "Loading custom emojis",
			loadingSystemImage: "face.smiling",
			onLoadMore: { await pager.loadMore() },
			onRefresh: { await pager.refresh() }
		) { emoji in
			HStack {
				if let url = URL(string: emoji.url) {
					AvatarImage(url)
				}
				VStack(alignment: .leading) {
					Text(emoji.name)
					PillView(Date.fromToString(emoji.createdAt), icon: Icons.clock.rawValue)
						.font(.footnote)
				}
			}
		}.task {
			await pager.start(query(), setCursor: { $0.after = .some($1) })
		}.navigationTitle("Custom Emojis")
	}
}

#Preview {
	NavigationStack {
		CustomEmojisLoader(fullPath: "gitlab-org")
	}
}
