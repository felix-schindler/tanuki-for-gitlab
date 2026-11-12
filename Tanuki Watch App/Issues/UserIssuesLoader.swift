//
//  UserIssuesLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 31.10.21.
//  Rewritten by Felix Schindler on 07.03.24.
//

import Apollo
import GitLabAPI
import SwiftUI

private struct DisplayIssue: Identifiable {
	let id: String
	let fullPath: String
	let issue: any SmallIssue
}

struct UserIssuesLoader: View {
	private static let maxIssues = 100

	@State
	private var issues: Result<[DisplayIssue], Error>? = nil

	private func query() -> CurrentUserIssuesQuery {
		CurrentUserIssuesQuery(
			state: .some(.case(.opened)),
			search: .none,
			confidential: .none,
			subscribed: .none,
			types: .none,
			labels: .none,
			milestones: .none,
			authorUsername: .none,
			assigneeUsernames: .none,
			createdAfter: .none,
			createdBefore: .none,
			updatedAfter: .none,
			updatedBefore: .none
		)
	}

	private func flatten(
		_ memberships: [IssueProjectMembership?]
	) -> [DisplayIssue] {
		var result: [DisplayIssue] = []
		for membership in memberships.compactMap({ $0 }) {
			guard let fullPath = membership.fullPath,
				let nodes = membership._issues
			else {
				continue
			}
			for issue in nodes.compactMap({ $0 }) {
				result.append(
					DisplayIssue(
						id: "\(fullPath)#\(issue.iid)",
						fullPath: fullPath,
						issue: issue
					)
				)
				if result.count >= Self.maxIssues {
					return result
				}
			}
		}
		return result
	}

	private func load() async {
		do {
			// NOTE: the literal `.cacheAndNetwork` must stay inline — Apollo
			// overloads `fetch` on the concrete `CachePolicy.Query.*` types,
			// so a generic `CachePolicy` parameter does not compile.
			let responses = try Network.shared.apollo.fetch(
				query: query(),
				cachePolicy: .cacheAndNetwork
			)

			for try await response in responses {
				try Task.checkCancellation()
				if let nodes = response.data?.currentUser?.projectMemberships?.nodes {
					self.issues = .success(flatten(nodes))
				}
			}
		} catch {
			if error is CancellationError {
				return
			}
			self.issues = .failure(error)
		}
	}

	private func reload() async {
		do {
			let response = try await Network.shared.apollo.fetch(
				query: query(),
				cachePolicy: .networkOnly
			)

			if let nodes = response.data?.currentUser?.projectMemberships?.nodes {
				self.issues = .success(flatten(nodes))
			}
		} catch {
			if error is CancellationError {
				return
			}
			self.issues = .failure(error)
		}
	}

	public var body: some View {
		List {
			if InstanceManager.selected == nil {
				NoContentView(
					"No instance selected. Add an instance on iPhone first.",
					systemImage: "server.rack"
				)
			} else if let issues {
				switch issues {
				case .success(let issues):
					if issues.isEmpty {
						NoContentView("All caught up!", systemImage: "smallcircle.circle")
					} else {
						ForEach(issues) { display in
							SmallIssueView(display.fullPath, display.issue)
						}
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				ProgressView("Loading issues")
			}
		}
		.task(id: InstanceManager.selected?.id) {
			issues = nil
			WatchSync.shared.requestContextRefresh()
			await load()
		}
		.refreshable {
			await reload()
		}
	}
}

#Preview {
	UserIssuesLoader()
}
