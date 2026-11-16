//
//  GroupProjectsLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 30.10.21.
//  Rewritten by Felix Schindler on 29.02.24.
//

import GitLabAPI
import SwiftUI

struct GroupProjectsLoader: View {
	private let fullPath: String

	@State
	private var pager = PagedQuery<GroupProjectsQuery, SmallProject>(
		extract: { ($0.group?.projects.nodes ?? []).compactMap { $0 } },
		key: { $0.fullPath },
		hasNext: { $0.group?.projects.pageInfo.hasNextPage ?? false },
		endCursor: { $0.group?.projects.pageInfo.endCursor }
	)

	init(fullPath: String) {
		self.fullPath = fullPath
	}

	private func query(after: GraphQLNullable<String> = .none) -> GroupProjectsQuery {
		GroupProjectsQuery(first: 50, after: after, fullPath: fullPath)
	}

	public var body: some View {
		LoadableList(
			pager.state,
			hasMore: pager.hasMore,
			emptyMessage: "The group \(self.fullPath) doesn't have any projects",
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
		GroupProjectsLoader(fullPath: "gitlab-org")
	}
}
