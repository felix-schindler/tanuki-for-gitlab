//
//  Issues.swift
//  Tanuki
//
//  Created by Felix Schindler on 31.10.21.
//  Rewritten by Felix Schindler on 26.02.24.
//

import GitLabAPI
import SwiftUI

struct ProjectIssuesLoader: View {
	/// Path of project to load issues from
	private let fullPath: String

	@State
	public var filter = IssueFilter()

	@State
	private var showFilters = false

	@State
	private var loadTask: Task<Void, Never>?

	@State
	private var project: Result<GitLabAPI.ProjectIssuesQuery.Data.Project, Error>? = nil

	init(fullPath: String) {
		self.fullPath = fullPath
	}

	private var query: ProjectIssuesQuery {
		ProjectIssuesQuery(
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
					if let project = response.data?.project {
						self.project = .success(project)
					} else if let errors = response.errors {
						for error in errors {
							Notify.status(.error, error.localizedDescription)
						}
					}
				}
			} catch {
				if !Task.isCancelled {
					self.project = .failure(error)
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

			if let project = response.data?.project {
				self.project = .success(project)
			}

			Notify.status(.success)
		} catch let error {
			self.project = .failure(error)
			Notify.status(.error)
		}
	}

	public var body: some View {
		List {
			if let project {
				switch project {
				case .success(let project):
					if !(project.issuesEnabled ?? false) {
						NoContentView(
							"Issues are not enabled for this project",
							systemImage: Icons.issues.rawValue
						)
					} else if let issues = project.issues?.nodes {
						if issues.isEmpty {
							NoContentView(
								"There are no issues", systemImage: Icons.issues.rawValue)
						} else {
							ForEach(issues, id: \.?.iid) { issue in
								if let issue {
									SmallIssueView(self.fullPath, issue)
								}
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
			HStack {
				if let project,
					case .success(let project) = project,
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
