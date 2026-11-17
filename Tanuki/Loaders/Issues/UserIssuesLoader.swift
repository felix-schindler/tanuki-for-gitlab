//
//  UserIssuesLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 31.10.21.
//  Rewritten by Felix Schindler on 07.03.24.
//

import GitLabAPI
import SwiftUI
import TanukiShared

struct UserIssuesLoader: View {
	private let username: String?

	@State
	public var filter = IssueFilter()

	@State
	private var showFilters = false

	init(username: String? = nil) {
		self.username = username
	}

	@State
	private var userLoader = ApolloLoader<UserIssuesQuery, [IssueProjectMembership?]> {
		$0.user?.projectMemberships?.nodes
	}

	@State
	private var currentLoader = ApolloLoader<CurrentUserIssuesQuery, [IssueProjectMembership?]> {
		$0.currentUser?.projectMemberships?.nodes
	}

	private var userQuery: UserIssuesQuery? {
		guard let username else { return nil }

		return UserIssuesQuery(
			username: username,
			state: GraphFilter.toFilterEnum(self.filter.state),
			search: GraphFilter.toFilter(self.filter.search),
			confidential: GraphFilter.toFilter(self.filter.confidential),
			subscribed: GraphFilter.toFilterEnum(self.filter.subscribed),
			types: self.filter.types != nil ? .some([.case(self.filter.types!)]) : .none,
			labels: GraphFilter.toFilter(self.filter.labelNames),
			milestones: GraphFilter.toFilter(self.filter.milestoneTitles),
			createdAfter: GraphFilter.toFilterDate(self.filter.createdAfter),
			createdBefore: GraphFilter.toFilterDate(self.filter.createdBefore),
			updatedAfter: GraphFilter.toFilterDate(self.filter.updatedAfter),
			updatedBefore: GraphFilter.toFilterDate(self.filter.updatedBefore)
		)
	}

	private var currentUserQuery: CurrentUserIssuesQuery {
		CurrentUserIssuesQuery(
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

	private var projectMemberships: Loadable<[IssueProjectMembership?]> {
		userQuery == nil ? currentLoader.state : userLoader.state
	}

	private func load() async {
		if let query = userQuery {
			await userLoader.load(query)
		} else {
			await currentLoader.load(currentUserQuery)
		}
	}

	private func reload() async {
		if let query = userQuery {
			await userLoader.reload(query)
		} else {
			await currentLoader.reload(currentUserQuery)
		}
	}

	public var body: some View {
		let state = self.projectMemberships

		List {
			if state.isInitialLoading {
				LoadingView("Loading Issues", systemImage: Icons.issues.rawValue, color: .green)
			} else if state.isColdFailure, let error = state.error {
				FailedView(error)
			} else if let projectMemberships = state.value {
				let validMemberships = projectMemberships.compactMap { $0 }
					.filter {
						$0.fullPath != nil && ($0._issues?.contains { $0 != nil } ?? false)
					}

				let issues: [(String, any SmallIssue)] = validMemberships.flatMap {
					membership in
					let fullPath = membership.fullPath!  // safe because we filtered nil above
					return membership._issues!.compactMap { $0 }.map { issue in
						(fullPath, issue)
					}
				}

				if issues.isEmpty {
					NoContentView(
						"All caught up!", systemImage: Icons.issues.rawValue,
						description: "There are no Issues")
				} else {
					ForEach(0..<issues.count, id: \.self) { index in
						let (fullPath, issue) = issues[index]
						SmallIssueView(fullPath, issue)
					}
				}
			}

		}.debouncedLoad(filter) {
			await load()
		}.refreshable {
			await reload()
		}.toolbar {
			Button("Filter", systemImage: Icons.filter.rawValue) {
				showFilters = true
			}
		}.sheet(isPresented: $showFilters) {
			IssueFilterView(filter: $filter, showsPeople: self.username == nil)
		}.searchable(
			text: Binding(get: { self.filter.search ?? "" }, set: { self.filter.search = $0.isNotEmpty ? $0 : nil }),
			prompt: "Search issues"
		).navigationTitle("Issues")
	}
}

#Preview {
	NavigationStack {
		UserIssuesLoader(username: "felix-schindler")
	}
}
