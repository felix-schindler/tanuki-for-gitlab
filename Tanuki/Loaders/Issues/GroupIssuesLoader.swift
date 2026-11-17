//
//  GroupIssuesLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 31.10.21.
//  Rewritten by Felix Schindler on 07.03.24.
//

import GitLabAPI
import SwiftUI
import TanukiShared

struct GroupIssuesLoader: View {
	private let fullPath: String

	@State
	public var filter = IssueFilter()

	@State
	private var showFilters = false

	init(fullPath: String) {
		self.fullPath = fullPath
	}

	@State
	private var pager = PagedQuery<GroupIssuesQuery, SmallIssue>(
		extract: { ($0.group?.issues?.nodes ?? []).compactMap { $0 } },
		key: { $0.reference },
		hasNext: { $0.group?.issues?.pageInfo.hasNextPage ?? false },
		endCursor: { $0.group?.issues?.pageInfo.endCursor }
	)

	private func query(after: GraphQLNullable<String> = .none) -> GroupIssuesQuery {
		GroupIssuesQuery(
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
			updatedBefore: GraphFilter.toFilterDate(self.filter.updatedBefore),
			includeSubgroups: .some(self.filter.includeSubgroups)
		)
	}

	public var body: some View {
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
		}.debouncedLoad(filter) {
			await pager.start(query(), setCursor: { $0.after = .some($1) })
		}.toolbar {
			Button("Filter", systemImage: Icons.filter.rawValue) {
				showFilters = true
			}
		}.sheet(isPresented: $showFilters) {
			IssueFilterView(filter: $filter, showsScope: true)
		}.searchable(
			text: Binding(get: { self.filter.search ?? "" }, set: { self.filter.search = $0.isNotEmpty ? $0 : nil }),
			prompt: "Search issues"
		).navigationTitle("Issues")
	}
}

#Preview {
	NavigationStack {
		GroupIssuesLoader(fullPath: "gitlab-org")
	}
}
