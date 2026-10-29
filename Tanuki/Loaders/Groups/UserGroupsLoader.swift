//
//  UserGroupsLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 29.02.24.
//

import GitLabAPI
import SwiftUI

struct UserGroupsLoader: View {
	private let username: String

	@State
	private var groups: Result<[Group?], Error>? = nil

	init(_ username: String) {
		self.username = username
	}

	private func loadGroups() {
		do {
			let responses = try Network.shared.apollo.fetch(
				query: UserGroupsQuery(username: username), cachePolicy: .cacheAndNetwork)

			Task {
				for try await response in responses {
					if let groups = response.data?.user?.groups?.nodes {
						self.groups = .success(groups)
					} else if let errors = response.errors {
						for error in errors {
							Notify.status(.error, error.localizedDescription)
						}
					}
				}
			}
		} catch let error {
			self.groups = .failure(error)
			Notify.status(.error)
		}
	}

	private func reloadGroups() async {
		do {
			let response = try await Network.shared.apollo.fetch(
				query: UserGroupsQuery(username: username), cachePolicy: .networkOnly)

			if let groups = response.data?.user?.groups?.nodes {
				self.groups = .success(groups)
			}

			Notify.status(.success)
		} catch let error {
			self.groups = .failure(error)
			Notify.status(.error)
		}
	}

	public var body: some View {
		List {
			if let groups {
				switch groups {
				case .success(let groups):
					if groups.isEmpty {
						NoContentView("There are no groups", systemImage: "scale.3d")
					} else {
						ForEach(groups, id: \.self?.fullPath) { group in
							if let group {
								SmallGroupView(group: group)
							}
						}
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading Groups", systemImage: "scale.3d")
			}
		}.task {
			loadGroups()
		}.refreshable {
			await reloadGroups()
		}.navigationTitle("Groups")
	}
}

#Preview {
	NavigationStack {
		UserGroupsLoader("felix-schindler")
	}
}
