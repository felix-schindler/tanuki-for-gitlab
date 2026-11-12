//
//  UserIssuesLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 31.10.21.
//  Rewritten by Felix Schindler on 07.03.24.
//

import GitLabAPI
import SwiftUI

struct UserIssuesLoader: View {
	private let username: String?

	@State
	public var filter = IssueFilter()

	@State
	private var showFilters = false

	@State
	private var loadTask: Task<Void, Never>?

	init(username: String? = nil) {
		self.username = username
	}

	@State
	private var projectMemberships: Result<[IssueProjectMembership?], Error>? = nil

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

	private func loadIssues() {
		self.loadTask?.cancel()
		self.loadTask = Task {
			do {
				if let query = self.userQuery {
					let responses = try Network.shared.apollo.fetch(
						query: query, cachePolicy: .cacheAndNetwork)

					for try await response in responses {
						if Task.isCancelled { return }
						if let projectMemberships = response.data?.user?.projectMemberships?.nodes {
							self.projectMemberships = .success(projectMemberships)
						} else if let errors = response.errors {
							for error in errors {
								Notify.status(.error, error.localizedDescription)
							}
						}
					}
				} else {
					let responses = try Network.shared.apollo.fetch(
						query: self.currentUserQuery, cachePolicy: .cacheAndNetwork)

					for try await response in responses {
						if Task.isCancelled { return }
						if let projectMemberships = response.data?.currentUser?.projectMemberships?
							.nodes
						{
							self.projectMemberships = .success(projectMemberships)
						} else if let errors = response.errors {
							for error in errors {
								Notify.status(.error, error.localizedDescription)
							}
						}
					}
				}
			} catch {
				if !Task.isCancelled {
					self.projectMemberships = .failure(error)
					Notify.status(.error)
				}
			}
		}
	}

	func reloadIssues() async {
		do {
			if let query = self.userQuery {
				let response = try await Network.shared.apollo.fetch(
					query: query, cachePolicy: .networkOnly)

				if let projectMemberships = response.data?.user?.projectMemberships?.nodes {
					self.projectMemberships = .success(projectMemberships)
				}
			} else {
				let response = try await Network.shared.apollo.fetch(
					query: self.currentUserQuery, cachePolicy: .networkOnly)

				if let projectMemberships = response.data?.currentUser?.projectMemberships?.nodes {
					self.projectMemberships = .success(projectMemberships)
				}
			}

			Notify.status(.success)
		} catch let error {
			self.projectMemberships = .failure(error)
			Notify.status(.error)
		}
	}

	public var body: some View {
		List {
			if let projectMemberships = self.projectMemberships {
				switch projectMemberships {
				case .success(let projectMemberships):
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
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading Issues", systemImage: Icons.issues.rawValue, color: .green)
			}
		}.debouncedLoad(filter) {
			loadIssues()
		}.refreshable {
			await reloadIssues()
		}.toolbar {
			Button("Filter", systemImage: Icons.filter.rawValue) {
				showFilters = true
			}
		}.sheet(isPresented: $showFilters) {
			// The current user's list can filter by people; a specific user's list
			// is already pinned to that author and assignee.
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
