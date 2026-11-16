//
//  CurrentUserTodosLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 08.03.24.
//

import GitLabAPI
import SwiftUI

struct CurrentUserTodosLoader: View {
	@State
	private var pager = PagedQuery<CurrentUserTodosQuery, Todo>(
		extract: { ($0.currentUser?.todos?.nodes ?? []).compactMap { $0 } },
		key: { $0.id },
		hasNext: { $0.currentUser?.todos?.pageInfo.hasNextPage ?? false },
		endCursor: { $0.currentUser?.todos?.pageInfo.endCursor }
	)

	private func query(after: GraphQLNullable<String> = .none) -> CurrentUserTodosQuery {
		CurrentUserTodosQuery(first: 50, after: after)
	}

	public var body: some View {
		LoadableList(
			pager.state,
			hasMore: pager.hasMore,
			emptyMessage: "All caught up!",
			emptySystemImage: Icons.todos.rawValue,
			emptyDescription: "There are no Todos",
			loadingMessage: "Loading your Todos",
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
		CurrentUserTodosLoader()
	}
}
