//
//  ProjectSnippetsLoader.swift
//  Tanuki
//

import GitLabAPI
import SwiftUI

struct ProjectSnippetsLoader: View {
	private let fullPath: String
	private let projectId: Int

	@State
	private var pager = PagedQuery<ProjectSnippetsQuery, ProjectSnippetsQuery.Data.Project.Snippets.Node>(
		extract: { ($0.project?.snippets?.nodes ?? []).compactMap { $0 } },
		key: { $0.id },
		hasNext: { $0.project?.snippets?.pageInfo.hasNextPage ?? false },
		endCursor: { $0.project?.snippets?.pageInfo.endCursor }
	)

	@State
	private var createSnippet = false

	init(fullPath: String, projectId: Int) {
		self.fullPath = fullPath
		self.projectId = projectId
	}

	private func query(after: GraphQLNullable<String> = .none) -> ProjectSnippetsQuery {
		ProjectSnippetsQuery(first: 50, after: after, fullPath: fullPath)
	}

	public var body: some View {
		LoadableList(
			pager.state,
			hasMore: pager.hasMore,
			emptyMessage: "There are no snippets",
			emptySystemImage: Icons.snippets.rawValue,
			loadingMessage: "Loading Snippets",
			loadingSystemImage: Icons.snippets.rawValue,
			onLoadMore: { await pager.loadMore() },
			onRefresh: { await pager.refresh() }
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
			await pager.start(query(), setCursor: { $0.after = .some($1) })
		}.toolbar {
			Button("New snippet", systemImage: "plus") {
				createSnippet = true
			}
		}.navigationDestination(isPresented: $createSnippet) {
			NewSnippetView(
				projectId: self.projectId,
				onCreated: {
					await pager.refresh(notify: false)
				})
		}.navigationTitle("Snippets")
	}
}

#Preview {
	NavigationStack {
		ProjectSnippetsLoader(fullPath: "felix-schindler/gitlab-ios", projectId: 43_985_992)
	}
}
