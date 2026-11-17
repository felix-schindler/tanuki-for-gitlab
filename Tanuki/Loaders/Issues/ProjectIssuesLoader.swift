//
//  Issues.swift
//  Tanuki
//
//  Created by Felix Schindler on 31.10.21.
//  Rewritten by Felix Schindler on 26.02.24.
//

import GitLabAPI
import SwiftUI
import TanukiShared

struct ProjectIssuesLoader: View {
	/// Path of project to load issues from
	private let fullPath: String

	@State
	public var filter = IssueFilter()

	@State
	private var showFilters = false

	@State
	private var pager = PagedQuery<ProjectIssuesQuery, ProjectIssuesQuery.Data.Project.Issues.Node>(
		extract: { ($0.project?.issues?.nodes ?? []).compactMap { $0 } },
		key: { $0.iid },
		hasNext: { $0.project?.issues?.pageInfo.hasNextPage ?? false },
		endCursor: { $0.project?.issues?.pageInfo.endCursor }
	)

	init(fullPath: String) {
		self.fullPath = fullPath
	}

	private func query(after: GraphQLNullable<String> = .none) -> ProjectIssuesQuery {
		ProjectIssuesQuery(
			first: 50,
			after: after,
			fullPath: self.fullPath,
			state: GraphFilter.toFilterEnum(self.filter.state),
			search: GraphFilter.toFilter(self.filter.search),
			confidential: GraphFilter.toFilter(self.filter.confidential),
			subscribed: GraphFilter.toFilterEnum(self.filter.subscribed),
			types: self.filter.types != nil ? .some([.case(self.filter.types!)]) : .none,
			labels: GraphFilter.toFilter(self.filter.labelNames),
			milestones: GraphFilter.toFilter(self.filter.milestoneTitles),
			authorUsername: GraphFilter.toFilter(self.filter.author),
			assigneeUsernames: GraphFilter.toFilter(self.filter.assignees),
			createdAfter: GraphFilter.toFilterDate(self.filter.createdAfter),
			createdBefore: GraphFilter.toFilterDate(self.filter.createdBefore),
			updatedAfter: GraphFilter.toFilterDate(self.filter.updatedAfter),
			updatedBefore: GraphFilter.toFilterDate(self.filter.updatedBefore)
		)
	}

	public var body: some View {
		SwiftUI.Group {
			if pager.firstPage?.project?.issuesEnabled == false {
				NoContentView(
					"Issues are not enabled for this project",
					systemImage: Icons.issues.rawValue
				)
			} else {
				LoadableList(
					pager.state,
					hasMore: pager.hasMore,
					emptyMessage: "There are no issues",
					emptySystemImage: Icons.issues.rawValue,
					loadingMessage: "Loading Issues",
					loadingSystemImage: Icons.issues.rawValue,
					onLoadMore: { await pager.loadMore() },
					onRefresh: { await pager.refresh() }
				) { issue in
					SmallIssueView(self.fullPath, issue)
				}
			}
		}.debouncedLoad(filter) {
			await pager.start(query(), setCursor: { $0.after = .some($1) })
		}.toolbar {
			HStack {
				if let project = pager.firstPage?.project,
					let projectId = project.id.toIntId()
				{
					NavigationLink(
						destination: NewIssueView(id: projectId, fullPath: self.fullPath),
						label: {
							Label("New issue", systemImage: "plus")
						}
					).tint(.accentColor)
				}

				Button("Filter", systemImage: Icons.filter.rawValue) {
					showFilters = true
				}
			}
		}.sheet(isPresented: $showFilters) {
			IssueFilterView(filter: $filter)
		}.searchable(
			text: Binding(get: { self.filter.search ?? "" }, set: { self.filter.search = $0.isNotEmpty ? $0 : nil }),
			prompt: "Search issues"
		).navigationTitle("Issues")
	}
}

#Preview {
	NavigationStack {
		ProjectIssuesLoader(fullPath: "felix-schindler/gitlab-ios")
	}
}
