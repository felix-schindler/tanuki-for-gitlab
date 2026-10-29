//
//  MergeRequests.swift
//  Tanuki
//
//  Created by Felix Schindler on 26.02.24.
//

import GitLabAPI
import SwiftUI

struct ProjectMergeLoader: View {
	private let fullPath: String

	@State
	public var filter = MergeRequestFilter()

	@State
	private var showFilters = false

	@State
	private var loadTask: Task<Void, Never>?

	@State
	private var project: Result<GitLabAPI.ProjectMergeRequestsQuery.Data.Project, Error>? = nil

	init(fullPath: String) {
		self.fullPath = fullPath
		self.project = nil
	}

	private var query: ProjectMergeRequestsQuery {
		return ProjectMergeRequestsQuery(
			fullPath: self.fullPath,
			state: GraphFilter.toFilterEnum(self.filter.state),
			search: GraphFilter.toFilter(self.filter.search),
			draft: GraphFilter.toFilter(self.filter.draft),
			subscribed: GraphFilter.toFilterEnum(self.filter.subscribed)
		)
	}

	private func loadMergeRequests() {
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

	private func reloadMergeRequests() async {
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
					if let mergeRequestsEnabled = project.mergeRequestsEnabled,
						!mergeRequestsEnabled
					{
						NoContentView(
							"Merge requests are not enabled for this project",
							image: "git-mr.symbols"
						)
					} else if let mrs = project.mergeRequests?.nodes {
						if mrs.count == 0 {
							NoContentView("There are no merge requests", image: "git-mr.symbols")
						} else {
							ForEach(mrs, id: \.?.iid) { mr in
								if let mr {
									SmallMergeView(self.fullPath, mr)
								}
							}
						}
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading Merge Requests", image: "git-mr.symbols", color: .blue)
			}
		}.task {
			loadMergeRequests()
		}.refreshable {
			await reloadMergeRequests()
		}.toolbar {
			Button("Filter", systemImage: "line.3.horizontal.decrease") {
				showFilters = true
			}
		}.sheet(isPresented: $showFilters, onDismiss: { self.showFilters = false }) {
			NavigationStack {
				MergeRequestFilterView(filter: $filter)
					.toolbar {
						AsyncButton("Apply filter", systemImage: "checkmark") {
							await reloadMergeRequests()
							showFilters = false
						}
					}
			}
		}.searchable(
			text: Binding(get: { self.filter.search ?? "" }, set: { self.filter.search = $0.isNotEmpty ? $0 : nil }),
			prompt: "Search merge requests"
		).onChange(of: filter.search) {
			self.project = nil  // Show loading state
			loadMergeRequests()
		}.navigationTitle("Merge Requests")
	}
}

#Preview {
	NavigationStack {
		ProjectMergeLoader(fullPath: "felix-schindler/gitlab-ios")
	}
}
