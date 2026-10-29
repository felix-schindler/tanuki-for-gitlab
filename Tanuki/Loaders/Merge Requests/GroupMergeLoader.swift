//
//  GroupMergeLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 05.03.24.
//

import GitLabAPI
import SwiftUI

struct GroupMergeLoader: View {
	private let fullPath: String

	@State
	public var filter = MergeRequestFilter()

	@State
	private var showFilters = false

	@State
	private var loadTask: Task<Void, Never>?

	@State
	private var mergeRequests: Result<[SmallMergeRequest?], Error>? = nil

	init(fullPath: String) {
		self.fullPath = fullPath
	}

	private var query: GroupMergeRequestsQuery {
		return GroupMergeRequestsQuery(
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
					if let mrs = response.data?.group?.mergeRequests?.nodes {
						self.mergeRequests = .success(mrs)
					} else if let errors = response.errors {
						for error in errors {
							Notify.status(.error, error.localizedDescription)
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
			let response = try await Network.shared.apollo.fetch(
				query: self.query,
				cachePolicy: .networkOnly
			)

			if let mrs = response.data?.group?.mergeRequests?.nodes {
				self.mergeRequests = .success(mrs)
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
				case .success(let mrs):
					if mrs.isEmpty {
						NoContentView("There are no Merge Requests", image: "git-mr.symbols")
					} else {
						ForEach(mrs, id: \.?.reference) { maybeMerge in
							if let mr = maybeMerge,
								let fullPath = mr.reference.split(separator: "!").first
							{
								SmallMergeView(String(fullPath), mr)
							}
						}
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView(
					"Loading Merge Requests", image: "git-mr.symbols", color: .blue)
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
			self.mergeRequests = nil  // Show loading state
			loadMergeRequests()
		}.navigationTitle("Merge Requests")
	}
}

#Preview {
	NavigationStack {
		GroupMergeLoader(fullPath: "gitlab-org")
	}
}
