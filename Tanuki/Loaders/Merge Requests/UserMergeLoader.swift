//
//  UserMergeLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 28.02.24.
//

import GitLabAPI
import SwiftUI
import TanukiShared

enum UserMergeRequestType {
	case assgined,
		authored,
		reviewRequested
}

struct UserMergeLoader: View {
	private var userRequestType: UserMergeRequestType
	private var navTitle: String

	@State
	public var filter = MergeRequestFilter()

	@State
	private var showFilters = false

	@State
	private var assignedPager = PagedQuery<UserAssignedMergeRequestsQuery, UserSmallMergeRequest>(
		extract: { ($0.currentUser?.assignedMergeRequests?.nodes ?? []).compactMap { $0 } },
		key: { $0.reference },
		hasNext: { $0.currentUser?.assignedMergeRequests?.pageInfo.hasNextPage ?? false },
		endCursor: { $0.currentUser?.assignedMergeRequests?.pageInfo.endCursor }
	)

	@State
	private var authoredPager = PagedQuery<UserAuthoredMergeRequestsQuery, UserSmallMergeRequest>(
		extract: { ($0.currentUser?.authoredMergeRequests?.nodes ?? []).compactMap { $0 } },
		key: { $0.reference },
		hasNext: { $0.currentUser?.authoredMergeRequests?.pageInfo.hasNextPage ?? false },
		endCursor: { $0.currentUser?.authoredMergeRequests?.pageInfo.endCursor }
	)

	@State
	private var reviewPager = PagedQuery<UserReviewRequestedMergeRequestsQuery, UserSmallMergeRequest>(
		extract: { ($0.currentUser?.reviewRequestedMergeRequests?.nodes ?? []).compactMap { $0 } },
		key: { $0.reference },
		hasNext: { $0.currentUser?.reviewRequestedMergeRequests?.pageInfo.hasNextPage ?? false },
		endCursor: { $0.currentUser?.reviewRequestedMergeRequests?.pageInfo.endCursor }
	)

	init(_ userRequestType: UserMergeRequestType) {
		self.userRequestType = userRequestType

		self.navTitle =
			switch self.userRequestType {
			case .assgined:
				"Assigned MRs"
			case .authored:
				"Authored MRs"
			case .reviewRequested:
				"Review requests MRs"
			}
	}

	private func assignedQuery(after: GraphQLNullable<String> = .none) -> UserAssignedMergeRequestsQuery {
		return UserAssignedMergeRequestsQuery(
			first: 50,
			after: after,
			state: GraphFilter.toFilterEnum(self.filter.state),
			search: GraphFilter.toFilter(self.filter.search),
			draft: GraphFilter.toFilter(self.filter.draft),
			subscribed: GraphFilter.toFilterEnum(self.filter.subscribed),
			labels: GraphFilter.toFilter(self.filter.labelNames),
			milestone: GraphFilter.toFilter(self.filter.milestoneTitle),
			createdAfter: GraphFilter.toFilterDate(self.filter.createdAfter),
			createdBefore: GraphFilter.toFilterDate(self.filter.createdBefore),
			updatedAfter: GraphFilter.toFilterDate(self.filter.updatedAfter),
			updatedBefore: GraphFilter.toFilterDate(self.filter.updatedBefore)
		)
	}

	private func authoredQuery(after: GraphQLNullable<String> = .none) -> UserAuthoredMergeRequestsQuery {
		return UserAuthoredMergeRequestsQuery(
			first: 50,
			after: after,
			state: GraphFilter.toFilterEnum(self.filter.state),
			search: GraphFilter.toFilter(self.filter.search),
			draft: GraphFilter.toFilter(self.filter.draft),
			subscribed: GraphFilter.toFilterEnum(self.filter.subscribed),
			labels: GraphFilter.toFilter(self.filter.labelNames),
			milestone: GraphFilter.toFilter(self.filter.milestoneTitle),
			createdAfter: GraphFilter.toFilterDate(self.filter.createdAfter),
			createdBefore: GraphFilter.toFilterDate(self.filter.createdBefore),
			updatedAfter: GraphFilter.toFilterDate(self.filter.updatedAfter),
			updatedBefore: GraphFilter.toFilterDate(self.filter.updatedBefore)
		)
	}

	private func reviewRequestedQuery(after: GraphQLNullable<String> = .none) -> UserReviewRequestedMergeRequestsQuery {
		return UserReviewRequestedMergeRequestsQuery(
			first: 50,
			after: after,
			state: GraphFilter.toFilterEnum(self.filter.state),
			search: GraphFilter.toFilter(self.filter.search),
			draft: GraphFilter.toFilter(self.filter.draft),
			subscribed: GraphFilter.toFilterEnum(self.filter.subscribed),
			labels: GraphFilter.toFilter(self.filter.labelNames),
			milestone: GraphFilter.toFilter(self.filter.milestoneTitle),
			createdAfter: GraphFilter.toFilterDate(self.filter.createdAfter),
			createdBefore: GraphFilter.toFilterDate(self.filter.createdBefore),
			updatedAfter: GraphFilter.toFilterDate(self.filter.updatedAfter),
			updatedBefore: GraphFilter.toFilterDate(self.filter.updatedBefore)
		)
	}

	private var state: Loadable<[UserSmallMergeRequest]> {
		switch userRequestType {
		case .assgined: assignedPager.state
		case .authored: authoredPager.state
		case .reviewRequested: reviewPager.state
		}
	}

	private var hasMore: Bool {
		switch userRequestType {
		case .assgined: assignedPager.hasMore
		case .authored: authoredPager.hasMore
		case .reviewRequested: reviewPager.hasMore
		}
	}

	private func load() async {
		switch userRequestType {
		case .assgined:
			await assignedPager.start(
				assignedQuery(), setCursor: { $0.after = .some($1) })
		case .authored:
			await authoredPager.start(
				authoredQuery(), setCursor: { $0.after = .some($1) })
		case .reviewRequested:
			await reviewPager.start(
				reviewRequestedQuery(), setCursor: { $0.after = .some($1) })
		}
	}

	private func refresh() async {
		switch userRequestType {
		case .assgined: await assignedPager.refresh()
		case .authored: await authoredPager.refresh()
		case .reviewRequested: await reviewPager.refresh()
		}
	}

	private func loadMore() async {
		switch userRequestType {
		case .assgined: await assignedPager.loadMore()
		case .authored: await authoredPager.loadMore()
		case .reviewRequested: await reviewPager.loadMore()
		}
	}

	public var body: some View {
		LoadableList(
			state,
			hasMore: hasMore,
			emptyMessage: "There are no merge requests",
			emptySystemImage: Images.mergeRequest.rawValue,
			loadingMessage: "Loading Merge Requests",
			loadingSystemImage: Images.mergeRequest.rawValue,
			onLoadMore: { await loadMore() },
			onRefresh: { await refresh() }
		) { mr in
			SmallMergeView(mr._project.fullPath, mr)
		}.debouncedLoad(filter) {
			await load()
		}.toolbar {
			Button("Filter", systemImage: Icons.filter.rawValue) {
				showFilters = true
			}
		}.sheet(isPresented: $showFilters) {
			MergeRequestFilterView(filter: $filter, showsPeople: false)
		}.searchable(
			text: Binding(get: { self.filter.search ?? "" }, set: { self.filter.search = $0.isNotEmpty ? $0 : nil }),
			prompt: "Search merge requests"
		).navigationTitle(self.navTitle)
	}
}

#Preview {
	NavigationStack {
		UserMergeLoader(.authored)
	}
}
