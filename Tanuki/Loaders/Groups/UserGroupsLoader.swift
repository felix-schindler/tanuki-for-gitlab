//
//  UserGroupsLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 29.02.24.
//

import GitLabAPI
import SwiftUI

struct UserGroupsLoader: View {
	private let username: String

	@State
	private var pager = PagedQuery<UserGroupsQuery, Group>(
		extract: { ($0.user?.groups?.nodes ?? []).compactMap { $0 } },
		key: { $0.fullPath },
		hasNext: { $0.user?.groups?.pageInfo.hasNextPage ?? false },
		endCursor: { $0.user?.groups?.pageInfo.endCursor }
	)

	init(_ username: String) {
		self.username = username
	}

	private func query(after: GraphQLNullable<String> = .none) -> UserGroupsQuery {
		UserGroupsQuery(first: 50, after: after, username: username)
	}

	public var body: some View {
		LoadableList(
			pager.state,
			id: \.fullPath,
			hasMore: pager.hasMore,
			emptyMessage: "There are no groups",
			emptySystemImage: Icons.groups.rawValue,
			loadingMessage: "Loading Groups",
			loadingSystemImage: Icons.groups.rawValue,
			onLoadMore: { await pager.loadMore() },
			onRefresh: { await pager.refresh() }
		) { group in
			SmallGroupView(group: group)
		}.task {
			await pager.start(query(), setCursor: { $0.after = .some($1) })
		}.navigationTitle("Groups")
	}
}

#Preview {
	NavigationStack {
		UserGroupsLoader("felix-schindler")
	}
}
