//
//  UserTodosLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 08.03.24.
//

import GitLabAPI
import SwiftUI

struct UserTodosLoader: View {
	private let username: String

	@State
	private var pager = PagedQuery<UserTodosQuery, Todo>(
		extract: { ($0.user?.todos?.nodes ?? []).compactMap { $0 } },
		key: { $0.id },
		hasNext: { $0.user?.todos?.pageInfo.hasNextPage ?? false },
		endCursor: { $0.user?.todos?.pageInfo.endCursor }
	)

	init(username: String) {
		self.username = username
	}

	private func query(after: GraphQLNullable<String> = .none) -> UserTodosQuery {
		UserTodosQuery(first: 50, after: after, username: username)
	}

	public var body: some View {
		LoadableList(
			pager.state,
			hasMore: pager.hasMore,
			emptyMessage: "All caught up!",
			emptySystemImage: Icons.todos.rawValue,
			emptyDescription: "There are no Todos",
			loadingMessage: "Loading Todos",
			loadingSystemImage: Icons.todos.rawValue,
			onLoadMore: { await pager.loadMore() },
			onRefresh: { await pager.refresh() }
		) { todo in
			TodoView(todo) {
				await pager.refresh()
			}
		}.task {
			await pager.start(query(), setCursor: { $0.after = .some($1) })
		}.navigationTitle("Todos")
	}
}

#Preview {
	NavigationStack {
		UserTodosLoader(username: "felix-schindler")
	}
}
