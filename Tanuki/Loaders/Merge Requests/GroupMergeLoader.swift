//
//  GroupMergeLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 05.03.24.
//

import GitLabAPI
import SwiftUI
import TanukiShared

struct GroupMergeLoader: View {
	private let fullPath: String

	@State
	public var filter = MergeRequestFilter()

	@State
	private var showFilters = false

	@State
	private var pager = PagedQuery<GroupMergeRequestsQuery, SmallMergeRequest>(
		extract: { ($0.group?.mergeRequests?.nodes ?? []).compactMap { $0 } },
		key: { $0.reference },
		hasNext: { $0.group?.mergeRequests?.pageInfo.hasNextPage ?? false },
		endCursor: { $0.group?.mergeRequests?.pageInfo.endCursor }
	)

	init(fullPath: String) {
		self.fullPath = fullPath
	}

	private func query(after: GraphQLNullable<String> = .none) -> GroupMergeRequestsQuery {
		return GroupMergeRequestsQuery(
			first: 50,
			after: after,
			fullPath: self.fullPath,
			state: GraphFilter.toFilterEnum(self.filter.state),
			search: GraphFilter.toFilter(self.filter.search),
			draft: GraphFilter.toFilter(self.filter.draft),
			subscribed: GraphFilter.toFilterEnum(self.filter.subscribed),
			labels: GraphFilter.toFilter(self.filter.labelNames),
			milestone: GraphFilter.toFilter(self.filter.milestoneTitle),
			authorUsername: GraphFilter.toFilter(self.filter.author),
			assigneeUsername: GraphFilter.toFilter(self.filter.assignee),
			reviewerUsername: GraphFilter.toFilter(self.filter.reviewer),
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
			emptyMessage: "There are no Merge Requests",
			emptySystemImage: Images.mergeRequest.rawValue,
			loadingMessage: "Loading Merge Requests",
			loadingSystemImage: Images.mergeRequest.rawValue,
			onLoadMore: { await pager.loadMore() },
			onRefresh: { await pager.refresh() }
		) { mr in
			if let fullPath = mr.reference.split(separator: "!").first {
				SmallMergeView(String(fullPath), mr)
			}
		}.debouncedLoad(filter) {
			await pager.start(query(), setCursor: { $0.after = .some($1) })
		}.toolbar {
			Button("Filter", systemImage: Icons.filter.rawValue) {
				showFilters = true
			}
		}.sheet(isPresented: $showFilters) {
			MergeRequestFilterView(filter: $filter, showsScope: true)
		}.searchable(
			text: Binding(get: { self.filter.search ?? "" }, set: { self.filter.search = $0.isNotEmpty ? $0 : nil }),
			prompt: "Search merge requests"
		).navigationTitle("Merge Requests")
	}
}

#Preview {
	NavigationStack {
		GroupMergeLoader(fullPath: "gitlab-org")
	}
}
