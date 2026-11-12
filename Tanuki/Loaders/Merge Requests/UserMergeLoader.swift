//
//  UserMergeLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 28.02.24.
//

import GitLabAPI
import SwiftUI

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
	private var loadTask: Task<Void, Never>?

	@State
	private var mergeRequests: Result<[UserSmallMergeRequest?], Error>? = nil

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

	private func assignedQuery() -> UserAssignedMergeRequestsQuery {
		return UserAssignedMergeRequestsQuery(
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

	private func authoredQuery() -> UserAuthoredMergeRequestsQuery {
		return UserAuthoredMergeRequestsQuery(
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

	private func reviewRequestedQuery() -> UserReviewRequestedMergeRequestsQuery {
		return UserReviewRequestedMergeRequestsQuery(
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

	private func loadMergeRequests() {
		self.loadTask?.cancel()
		self.loadTask = Task {
			do {
				switch self.userRequestType {
				case .assgined:
					let responses = try Network.shared.apollo.fetch(
						query: self.assignedQuery(),
						cachePolicy: .cacheAndNetwork
					)

					for try await response in responses {
						if Task.isCancelled { return }
						if let mrs = response.data?.currentUser?.assignedMergeRequests?.nodes {
							self.mergeRequests = .success(mrs)
						} else if let errors = response.errors {
							for error in errors {
								Notify.status(.error, error.localizedDescription)
							}
						}
					}
				case .authored:
					let responses = try Network.shared.apollo.fetch(
						query: self.authoredQuery(),
						cachePolicy: .cacheAndNetwork
					)

					for try await response in responses {
						if Task.isCancelled { return }
						if let mrs = response.data?.currentUser?.authoredMergeRequests?.nodes {
							self.mergeRequests = .success(mrs)
						} else if let errors = response.errors {
							for error in errors {
								Notify.status(.error, error.localizedDescription)
							}
						}
					}
				case .reviewRequested:
					let responses = try Network.shared.apollo.fetch(
						query: self.reviewRequestedQuery(),
						cachePolicy: .cacheAndNetwork
					)

					for try await response in responses {
						if Task.isCancelled { return }
						if let mrs = response.data?.currentUser?.reviewRequestedMergeRequests?.nodes {
							self.mergeRequests = .success(mrs)
						} else if let errors = response.errors {
							for error in errors {
								Notify.status(.error, error.localizedDescription)
							}
						}
					}
				}
			} catch {
				if !Task.isCancelled {
					self.mergeRequests = .failure(error)
					Notify.status(.error)
				}
			}
		}
	}

	private func reloadMergeRequests() async {
		do {
			switch self.userRequestType {
			case .assgined:
				let response = try await Network.shared.apollo.fetch(
					query: self.assignedQuery(),
					cachePolicy: .networkOnly
				)

				if let mrs = response.data?.currentUser?.assignedMergeRequests?.nodes {
					self.mergeRequests = .success(mrs)
				}
			case .authored:
				let response = try await Network.shared.apollo.fetch(
					query: self.authoredQuery(),
					cachePolicy: .networkOnly
				)

				if let mrs = response.data?.currentUser?.authoredMergeRequests?.nodes {
					self.mergeRequests = .success(mrs)
				}
			case .reviewRequested:
				let response = try await Network.shared.apollo.fetch(
					query: self.reviewRequestedQuery(),
					cachePolicy: .networkOnly
				)

				if let mrs = response.data?.currentUser?.reviewRequestedMergeRequests?.nodes {
					self.mergeRequests = .success(mrs)
				}
			}

			Notify.status(.success)
		} catch let error {
			self.mergeRequests = .failure(error)
			Notify.status(.error)
		}
	}

	public var body: some View {
		List {
			if let mergeRequests {
				switch mergeRequests {
				case .success(let mergeRequests):
					if mergeRequests.isEmpty {
						NoContentView("There are no merge requests", image: Images.mergeRequest.rawValue)
					} else {
						ForEach(mergeRequests, id: \.?.reference) {
							maybeMerge in
							if let mr = maybeMerge {
								SmallMergeView(mr._project.fullPath, mr)
							}
						}
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading Merge Requests", image: Images.mergeRequest.rawValue, color: .blue)
			}
		}.debouncedLoad(filter) {
			loadMergeRequests()
		}.refreshable {
			await reloadMergeRequests()
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
