//
//  UserProjectsLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 30.10.21.
//  Rewritten by Felix Schindler on 29.02.24.
//

import GitLabAPI
import SwiftUI

struct UserProjectsLoader: View {
	private let username: String

	@State
	private var projects: Result<[UserMembershipProjectsQuery.Data.User.ProjectMemberships.Node.Project?], Error>? =
		nil

	init(username: String) {
		self.username = username
	}

	private func loadProjects() {
		do {
			let responses = try Network.shared.apollo.fetch(
				query: UserMembershipProjectsQuery(username: self.username),
				cachePolicy: .cacheAndNetwork
			)

			Task {
				for try await response in responses {
					if let nodes = response.data?.user?.projectMemberships?.nodes {
						self.projects = .success(nodes.map { $0?.project })
					} else if let errors = response.errors {
						for error in errors {
							Notify.status(.error, error.localizedDescription)
						}
					}
				}
			}
		} catch let error {
			self.projects = .failure(error)
			Notify.status(.error)
		}
	}

	private func reloadProjects() async {
		do {
			let response = try await Network.shared.apollo.fetch(
				query: UserMembershipProjectsQuery(username: self.username),
				cachePolicy: .networkOnly
			)

			if let nodes = response.data?.user?.projectMemberships?.nodes {
				self.projects = .success(nodes.map { $0?.project })
			}

			Notify.status(.success)
		} catch let error {
			self.projects = .failure(error)
			Notify.status(.error)
		}
	}

	public var body: some View {
		List {
			if let projects {
				switch projects {
				case .success(let projects):
					if projects.isEmpty {
						NoContentView("There are no projects", systemImage: "app.gift.fill")
					} else {
						ForEach(projects, id: \.?.fullPath) { maybeProject in
							if let project = maybeProject {
								SmallProjectView(project)
							}
						}
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading Projects", systemImage: "app.gift.fill")
			}
		}.task {
			loadProjects()
		}.refreshable {
			await reloadProjects()
		}.navigationTitle("Projects")
	}
}

#Preview {
	NavigationStack {
		UserProjectsLoader(username: "felix-schindler")
	}
}
