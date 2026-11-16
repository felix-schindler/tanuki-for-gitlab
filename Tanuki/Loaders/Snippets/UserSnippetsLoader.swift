//
//  UserSnippetsLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 29.02.24.
//

import GitLabAPI
import SwiftUI

struct UserSnippetsLoader: View {
	private let username: String?

	@State
	private var userPager = PagedQuery<UserSnippetsQuery, Snippet>(
		extract: { ($0.user?.snippets?.nodes ?? []).compactMap { $0 } },
		key: { $0.id },
		hasNext: { $0.user?.snippets?.pageInfo.hasNextPage ?? false },
		endCursor: { $0.user?.snippets?.pageInfo.endCursor }
	)

	@State
	private var currentPager = PagedQuery<CurrentUserSnippetsQuery, Snippet>(
		extract: { ($0.currentUser?.snippets?.nodes ?? []).compactMap { $0 } },
		key: { $0.id },
		hasNext: { $0.currentUser?.snippets?.pageInfo.hasNextPage ?? false },
		endCursor: { $0.currentUser?.snippets?.pageInfo.endCursor }
	)

	@State
	private var createSnippet = false

	init(username: String? = nil) {
		self.username = username
	}

	private var state: Loadable<[Snippet]> {
		username == nil ? currentPager.state : userPager.state
	}

	private var hasMore: Bool {
		username == nil ? currentPager.hasMore : userPager.hasMore
	}

	private func load() async {
		if let username {
			await userPager.start(
				UserSnippetsQuery(first: 50, after: .none, username: username),
				setCursor: { $0.after = .some($1) })
		} else {
			await currentPager.start(
				CurrentUserSnippetsQuery(first: 50, after: .none),
				setCursor: { $0.after = .some($1) })
		}
	}

	private func refresh(notify: Bool = true) async {
		if username == nil {
			await currentPager.refresh(notify: notify)
		} else {
			await userPager.refresh(notify: notify)
		}
	}

	private func loadMore() async {
		if username == nil {
			await currentPager.loadMore()
		} else {
			await userPager.loadMore()
		}
	}

	public var body: some View {
		LoadableList(
			state,
			hasMore: hasMore,
			emptyMessage: "There are no snippets",
			emptySystemImage: Icons.snippets.rawValue,
			loadingMessage: "Loading Snippets",
			loadingSystemImage: Icons.snippets.rawValue,
			onLoadMore: { await loadMore() },
			onRefresh: { await refresh() }
		) { snippet in
			NavigationLink(
				destination: SnippetLoader(id: snippet.id),
				label: {
					HStack {
						VStack(alignment: .leading) {
							HStack {
								VisibilityIcon(snippet.visibilityLevel.rawValue)
								Text(snippet.title.emojized())
							}

							ScrollView(.horizontal) {
								HStack {
									if let author = snippet._author {
										AuthorView(author)
									}

									PillView(
										Date.fromToString(snippet.createdAt),
										icon: Icons.clock.rawValue)
								}.font(.footnote)
							}
						}
					}.swipeActions {
						ShareButton(URL(string: snippet.webUrl)!)
					}
				}
			)
		}.task {
			await load()
		}.toolbar {
			if username == nil {
				Button("New snippet", systemImage: "plus") {
					createSnippet = true
				}
			}
		}.navigationDestination(isPresented: $createSnippet) {
			NewSnippetView(
				onCreated: {
					await refresh(notify: false)
				})
		}.navigationTitle("Snippets")
	}
}

#Preview {
	NavigationStack {
		UserSnippetsLoader(username: "felix-schindler")
	}
}
