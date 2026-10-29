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

	private func loadIssues() {
		self.loadTask?.cancel()
		self.loadTask = Task {
			do {
				if let username {
					let responses = try Network.shared.apollo.fetch(
						query: UserIssuesQuery(
							username: username,
							state: GraphFilter.toFilterEnum(self.filter.state),
							search: GraphFilter.toFilter(self.filter.search),
							confidential: GraphFilter.toFilter(self.filter.confidential),
							subscribed: GraphFilter.toFilterEnum(self.filter.subscribed),
							types: self.filter.types != nil ? .some([.case(self.filter.types!)]) : .none
						), cachePolicy: .cacheAndNetwork)

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
						query: CurrentUserIssuesQuery(
							state: GraphFilter.toFilterEnum(self.filter.state),
							search: GraphFilter.toFilter(self.filter.search),
							confidential: GraphFilter.toFilter(self.filter.confidential),
							subscribed: GraphFilter.toFilterEnum(self.filter.subscribed),
							types: self.filter.types != nil ? .some([.case(self.filter.types!)]) : .none
						), cachePolicy: .cacheAndNetwork)

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
			if let username {
				let response = try await Network.shared.apollo.fetch(
					query: UserIssuesQuery(
						username: username,
						state: GraphFilter.toFilterEnum(self.filter.state),
						search: GraphFilter.toFilter(self.filter.search),
						confidential: GraphFilter.toFilter(self.filter.confidential),
						subscribed: GraphFilter.toFilterEnum(self.filter.subscribed),
						types: self.filter.types != nil ? .some([.case(self.filter.types!)]) : .none
					), cachePolicy: .networkOnly)

				if let projectMemberships = response.data?.user?.projectMemberships?.nodes {
					self.projectMemberships = .success(projectMemberships)
				}
			} else {
				let response = try await Network.shared.apollo.fetch(
					query: CurrentUserIssuesQuery(
						state: GraphFilter.toFilterEnum(self.filter.state),
						search: GraphFilter.toFilter(self.filter.search),
						confidential: GraphFilter.toFilter(self.filter.confidential),
						subscribed: GraphFilter.toFilterEnum(self.filter.subscribed),
						types: self.filter.types != nil ? .some([.case(self.filter.types!)]) : .none
					), cachePolicy: .networkOnly)

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
							"All caught up!", systemImage: "smallcircle.circle",
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
				LoadingView("Loading Issues", systemImage: "smallcircle.circle", color: .green)
			}
		}.task {
			loadIssues()
		}.refreshable {
			await reloadIssues()
		}.toolbar {
			Button("Filter", systemImage: "line.3.horizontal.decrease") {
				showFilters = true
			}
		}.sheet(isPresented: $showFilters, onDismiss: { self.showFilters = false }) {
			NavigationStack {
				IssueFilterView(filter: $filter)
					.toolbar {
						AsyncButton("Apply filter", systemImage: "checkmark") {
							await reloadIssues()
							showFilters = false
						}
					}
			}
		}.searchable(
			text: Binding(get: { self.filter.search ?? "" }, set: { self.filter.search = $0.isNotEmpty ? $0 : nil }),
			prompt: "Search issues"
		).onChange(of: filter.search) {
			self.projectMemberships = nil  // Show loading state
			loadIssues()
		}.navigationTitle("Issues")
	}
}

#Preview {
	NavigationStack {
		UserIssuesLoader(username: "felix-schindler")
	}
}
