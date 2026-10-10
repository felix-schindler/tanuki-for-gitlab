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

	private func loadIssues() {
		self.loadTask?.cancel()
		self.loadTask = Task {
			do {
				let responses = try Network.shared.apollo.fetch(
					query: GroupIssuesQuery(
						fullPath: self.fullPath,
						state: GraphFilter.toFilterEnum(self.filter.state),
						search: GraphFilter.toFilter(self.filter.search),
						confidential: GraphFilter.toFilter(self.filter.confidential),
						subscribed: GraphFilter.toFilterEnum(self.filter.subscribed),
						types: self.filter.types != nil ? .some([.case(self.filter.types!)]) : .none
					),
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
				query: GroupIssuesQuery(
					fullPath: self.fullPath,
					state: GraphFilter.toFilterEnum(self.filter.state),
					search: GraphFilter.toFilter(self.filter.search),
					confidential: GraphFilter.toFilter(self.filter.confidential),
					subscribed: GraphFilter.toFilterEnum(self.filter.subscribed),
					types: self.filter.types != nil ? .some([.case(self.filter.types!)]) : .none
				),
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
				LoadingView("Loading Issues", lucide: .circleDot, color: .green)
			}
		}.task {
			loadIssues()
		}.refreshable {
			await reloadIssues()
		}.toolbar {
			Button("Filter", lucide: .listFilter) {
				showFilters = true
			}
		}.sheet(isPresented: $showFilters, onDismiss: { self.showFilters = false }) {
			NavigationStack {
				IssueFilterView(filter: $filter)
					.toolbar {
						AsyncButton("Apply filter", lucide: .check) {
							await reloadIssues()
							showFilters = false
						}
					}
			}
		}.searchable(
			text: Binding(get: { self.filter.search ?? "" }, set: { self.filter.search = $0.isNotEmpty ? $0 : nil }),
			prompt: "Search issues"
		).onChange(of: filter.search) {
			self.issues = nil  // Show loading state
			loadIssues()
		}.navigationTitle("Issues")
	}
}

#Preview {
	NavigationStack {
		GroupIssuesLoader(fullPath: "gitlab-org")
	}
}
