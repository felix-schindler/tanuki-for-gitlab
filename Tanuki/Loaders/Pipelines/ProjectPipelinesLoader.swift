//
//  ProjectPipelinesLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 07.03.24.
//

import GitLabAPI
import SwiftUI

struct ProjectPipelinesLoader: View {
	private var fullPath: String

	@State
	private var pager = PagedQuery<ProjectPipelinesQuery, ProjectPipelinesQuery.Data.Project.Pipelines.Node>(
		extract: { ($0.project?.pipelines?.nodes ?? []).compactMap { $0 } },
		key: { $0.id },
		hasNext: { $0.project?.pipelines?.pageInfo.hasNextPage ?? false },
		endCursor: { $0.project?.pipelines?.pageInfo.endCursor }
	)

	init(fullPath: String) {
		self.fullPath = fullPath
	}

	private func query(after: GraphQLNullable<String> = .none) -> ProjectPipelinesQuery {
		ProjectPipelinesQuery(first: 50, after: after, fullPath: fullPath)
	}

	public var body: some View {
		LoadableList(
			pager.state,
			id: \.id,
			hasMore: pager.hasMore,
			emptyMessage: "There are no pipelines",
			emptySystemImage: Icons.flag.rawValue,
			loadingMessage: "Loading Pipelines",
			loadingSystemImage: Icons.flag.rawValue,
			onLoadMore: { await pager.loadMore() },
			onRefresh: { await pager.refresh() }
		) { pipeline in
			NavigationLink(
				destination: PipelineLoader(fullPath: self.fullPath, iid: pipeline.iid)
			) {
				SmallPipelineView(pipeline)
			}
		}.task {
			await pager.start(query(), setCursor: { $0.after = .some($1) })
		}.navigationTitle("Pipelines")
	}
}

#Preview {
	NavigationStack {
		ProjectPipelinesLoader(fullPath: "felix-schindler/gitlab-ios")
	}
}
