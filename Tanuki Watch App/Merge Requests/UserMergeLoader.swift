//
//  UserMergeLoader.swift
//  Tanuki Watch App
//
//  Created by Felix Schindler on 28.02.24.
//

import Apollo
import GitLabAPI
import SwiftUI

enum UserMergeRequestType {
	case assigned
	case authored
	case reviewRequested
}

private struct DisplayMergeRequest: Identifiable {
	let id: String
	let fullPath: String
	let mr: any SmallMergeRequest
}

struct UserMergeLoader: View {
	private var userRequestType: UserMergeRequestType
	private var navTitle: String

	private static let maxMergeRequests = 100

	@State
	private var mergeRequests: Result<[DisplayMergeRequest], Error>? = nil

	init(_ userRequestType: UserMergeRequestType) {
		self.userRequestType = userRequestType

		self.navTitle =
			switch self.userRequestType {
			case .assigned:
				"Assigned MRs"
			case .authored:
				"Authored MRs"
			case .reviewRequested:
				"Review Requests"
			}
	}

	private func display(_ mr: any SmallMergeRequest) -> DisplayMergeRequest {
		DisplayMergeRequest(
			id: "\(mr._project.fullPath)#\(mr.iid)",
			fullPath: mr._project.fullPath,
			mr: mr
		)
	}

	private func capped(_ mrs: [any SmallMergeRequest]) -> [DisplayMergeRequest] {
		Array(mrs.map(display).prefix(Self.maxMergeRequests))
	}

	private func load() async {
		do {
			switch self.userRequestType {
			case .assigned:
				let responses = try Network.shared.apollo.fetch(
					query: UserAssignedMergeRequestsQuery(
						state: .none, search: .none, draft: .none, subscribed: .none, labels: .none, milestone: .none,
						createdAfter: .none, createdBefore: .none, updatedAfter: .none, updatedBefore: .none),
					cachePolicy: .cacheAndNetwork
				)
				for try await response in responses {
					try Task.checkCancellation()
					if let nodes = response.data?.currentUser?.assignedMergeRequests?.nodes {
						self.mergeRequests = .success(capped(nodes.compactMap { $0 }))
					}
				}
			case .authored:
				let responses = try Network.shared.apollo.fetch(
					query: UserAuthoredMergeRequestsQuery(
						state: .none, search: .none, draft: .none, subscribed: .none, labels: .none, milestone: .none,
						createdAfter: .none, createdBefore: .none, updatedAfter: .none, updatedBefore: .none),
					cachePolicy: .cacheAndNetwork
				)
				for try await response in responses {
					try Task.checkCancellation()
					if let nodes = response.data?.currentUser?.authoredMergeRequests?.nodes {
						self.mergeRequests = .success(capped(nodes.compactMap { $0 }))
					}
				}
			case .reviewRequested:
				let responses = try Network.shared.apollo.fetch(
					query: UserReviewRequestedMergeRequestsQuery(
						state: .none, search: .none, draft: .none, subscribed: .none, labels: .none, milestone: .none,
						createdAfter: .none, createdBefore: .none, updatedAfter: .none, updatedBefore: .none),
					cachePolicy: .cacheAndNetwork
				)
				for try await response in responses {
					try Task.checkCancellation()
					if let nodes = response.data?.currentUser?.reviewRequestedMergeRequests?.nodes {
						self.mergeRequests = .success(capped(nodes.compactMap { $0 }))
					}
				}
			}
		} catch {
			// SwiftUI cancels `.task` on disappear; a cancelled load must not
			// overwrite good data with a failure.
			if error is CancellationError {
				return
			}
			self.mergeRequests = .failure(error)
		}
	}

	private func reload() async {
		do {
			switch self.userRequestType {
			case .assigned:
				let response = try await Network.shared.apollo.fetch(
					query: UserAssignedMergeRequestsQuery(
						state: .none, search: .none, draft: .none, subscribed: .none, labels: .none, milestone: .none,
						createdAfter: .none, createdBefore: .none, updatedAfter: .none, updatedBefore: .none),
					cachePolicy: .networkOnly)
				let nodes = response.data?.currentUser?.assignedMergeRequests?.nodes ?? []
				self.mergeRequests = .success(capped(nodes.compactMap { $0 }))
			case .authored:
				let response = try await Network.shared.apollo.fetch(
					query: UserAuthoredMergeRequestsQuery(
						state: .none, search: .none, draft: .none, subscribed: .none, labels: .none, milestone: .none,
						createdAfter: .none, createdBefore: .none, updatedAfter: .none, updatedBefore: .none),
					cachePolicy: .networkOnly)
				let nodes = response.data?.currentUser?.authoredMergeRequests?.nodes ?? []
				self.mergeRequests = .success(capped(nodes.compactMap { $0 }))
			case .reviewRequested:
				let response = try await Network.shared.apollo.fetch(
					query: UserReviewRequestedMergeRequestsQuery(
						state: .none, search: .none, draft: .none, subscribed: .none, labels: .none, milestone: .none,
						createdAfter: .none, createdBefore: .none, updatedAfter: .none, updatedBefore: .none),
					cachePolicy: .networkOnly)
				let nodes = response.data?.currentUser?.reviewRequestedMergeRequests?.nodes ?? []
				self.mergeRequests = .success(capped(nodes.compactMap { $0 }))
			}
		} catch {
			if error is CancellationError {
				return
			}
			self.mergeRequests = .failure(error)
		}
	}

	public var body: some View {
		List {
			if InstanceManager.selected == nil {
				NoContentView(
					"No instance selected. Add an instance on iPhone first.",
					systemImage: "server.rack"
				)
			} else if let mergeRequests {
				switch mergeRequests {
				case .success(let mergeRequests):
					if mergeRequests.isEmpty {
						NoContentView(
							"There are no merge requests", systemImage: "arrow.triangle.branch")
					} else {
						ForEach(mergeRequests) { display in
							SmallMergeView(display.fullPath, display.mr)
						}
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				ProgressView("Loading merge requests")
			}
		}
		.task(id: InstanceManager.selected?.id) {
			mergeRequests = nil
			WatchSync.shared.requestContextRefresh()
			await load()
		}
		.refreshable {
			await reload()
		}
		.navigationTitle(self.navTitle)
	}
}

#Preview {
	NavigationStack {
		UserMergeLoader(.authored)
	}
}
