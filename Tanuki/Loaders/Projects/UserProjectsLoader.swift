//
//  UserProjectsLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 30.10.21.
//  Rewritten by Felix Schindler on 29.02.24.
//

import GitLabAPI
import SwiftUI

struct UserProjectsLoader: View {
	private let username: String

	@State
	private var pager = PagedQuery<UserMembershipProjectsQuery, SmallProject>(
		extract: { ($0.user?.projectMemberships?.nodes ?? []).compactMap { $0?.project } },
		key: { $0.fullPath },
		hasNext: { $0.user?.projectMemberships?.pageInfo.hasNextPage ?? false },
		endCursor: { $0.user?.projectMemberships?.pageInfo.endCursor }
	)

	init(username: String) {
		self.username = username
	}

	private func query(after: GraphQLNullable<String> = .none) -> UserMembershipProjectsQuery {
		UserMembershipProjectsQuery(first: 50, after: after, username: username)
	}

	public var body: some View {
		LoadableList(
			pager.state,
			id: \.fullPath,
			hasMore: pager.hasMore,
			emptyMessage: "There are no projects",
			emptySystemImage: Icons.projects.rawValue,
			loadingMessage: "Loading Projects",
			loadingSystemImage: Icons.projects.rawValue,
			onLoadMore: { await pager.loadMore() },
			onRefresh: { await pager.refresh() }
		) { project in
			SmallProjectView(project)
		}.task {
			await pager.start(query(), setCursor: { $0.after = .some($1) })
		}.navigationTitle("Projects")
	}
}

#Preview {
	NavigationStack {
		UserProjectsLoader(username: "felix-schindler")
	}
}
