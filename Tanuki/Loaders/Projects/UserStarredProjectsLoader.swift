//
//  UserStarredProjectsLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 30.10.21.
//  Rewritten by Felix Schindler on 03.03.24.
//

import GitLabAPI
import SwiftUI

struct UserStarredProjectsLoader: View {
	private let username: String

	@State
	private var pager = PagedQuery<UserStarredProjectsQuery, SmallProject>(
		extract: { ($0.user?.starredProjects?.nodes ?? []).compactMap { $0 } },
		key: { $0.fullPath },
		hasNext: { $0.user?.starredProjects?.pageInfo.hasNextPage ?? false },
		endCursor: { $0.user?.starredProjects?.pageInfo.endCursor }
	)

	init(username: String) {
		self.username = username
	}

	private func query(after: GraphQLNullable<String> = .none) -> UserStarredProjectsQuery {
		UserStarredProjectsQuery(first: 50, after: after, username: username)
	}

	public var body: some View {
		LoadableList(
			pager.state,
			id: \.fullPath,
			hasMore: pager.hasMore,
			emptyMessage: "There are no starred projects",
			emptySystemImage: Icons.star.rawValue,
			loadingMessage: "Loading starred Projects",
			loadingSystemImage: Icons.star.rawValue,
			onLoadMore: { await pager.loadMore() },
			onRefresh: { await pager.refresh() }
		) { project in
			SmallProjectView(project)
		}.task {
			await pager.start(query(), setCursor: { $0.after = .some($1) })
		}.navigationTitle("Stars of \(username)")
	}
}

#Preview {
	NavigationStack {
		UserStarredProjectsLoader(username: "felix-schindler")
	}
}
