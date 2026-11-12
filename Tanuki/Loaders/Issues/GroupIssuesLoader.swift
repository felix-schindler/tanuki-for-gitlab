//
//  GroupIssuesLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 31.10.21.
//  Rewritten by Felix Schindler on 07.03.24.
//

import GitLabAPI
import SwiftUI

struct GroupIssuesLoader: View {
	private let fullPath: String

	@State
	public var filter = IssueFilter()

	@State
	private var showFilters = false

	@State
	private var loadTask: Task<Void, Never>?

	init(fullPath: String) {
		self.fullPath = fullPath
	}

	@State
	private var issues: Result<[SmallIssue?], Error>? = nil

	private var query: GroupIssuesQuery {
		GroupIssuesQuery(
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

	private func loadIssues() {
		self.loadTask?.cancel()
		self.loadTask = Task {
			do {
				let responses = try Network.shared.apollo.fetch(
					query: self.query,
					cachePolicy: .cacheAndNetwork
				)

				for try await response in responses {
					if Task.isCancelled { return }
					if let issues = response.data?.group?.issues?.nodes {
						self.issues = .success(issues)
					} else if let errors = response.errors {
						for error in errors {
							Notify.status(.error, error.localizedDescription)
						}
					}
				}
			} catch {
				if !Task.isCancelled {
					self.issues = .failure(error)
					Notify.status(.error)
				}
			}
		}
	}

	private func reloadIssues() async {
		do {
			let response = try await Network.shared.apollo.fetch(
				query: self.query,
				cachePolicy: .networkOnly
			)

			if let issues = response.data?.group?.issues?.nodes {
				self.issues = .success(issues)
			}

			Notify.status(.success)
		} catch let error {
			self.issues = .failure(error)
			Notify.status(.error)
		}
	}

	public var body: some View {
		List {
			if let issues {
				switch issues {
				case .success(let issues):
					if issues.isEmpty {
						Text("There are no issues")
					} else {
						ForEach(issues, id: \.?.reference) { maybeIssue in
							if let issue = maybeIssue {
								SmallIssueView(self.fullPath, issue)
							}
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
