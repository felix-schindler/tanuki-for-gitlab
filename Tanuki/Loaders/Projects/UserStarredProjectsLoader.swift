//
//  UserStarredProjectsLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 30.10.21.
//  Rewritten by Felix Schindler on 03.03.24.
//

import GitLabAPI
import SwiftUI

struct UserStarredProjectsLoader: View {
	private let username: String

	@State
	private var projects: Result<[UserStarredProjectsQuery.Data.User.StarredProjects.Node?], Error>? =
		nil

	init(username: String) {
		self.username = username
	}

	private func loadProjects() {
		do {
			let responses = try Network.shared.apollo.fetch(
				query: UserStarredProjectsQuery(username: self.username),
				cachePolicy: .cacheAndNetwork
			)

			Task {
				for try await response in responses {
					if let projects = response.data?.user?.starredProjects?.nodes {
						self.projects = .success(projects)
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
				query: UserStarredProjectsQuery(username: self.username),
				cachePolicy: .networkOnly
			)

			if let projects = response.data?.user?.starredProjects?.nodes {
				self.projects = .success(projects)
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
						NoContentView("There are no starred projects", systemImage: "star")
					} else {
						ForEach(projects, id: \.self?.fullPath) { maybeProject in
							if let project = maybeProject {
								SmallProjectView(project)
							}
						}
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading starred Projects", systemImage: "star")
			}
		}.task {
			loadProjects()
		}.refreshable {
			await reloadProjects()
		}.navigationTitle("Stars of \(username)")
	}
}

#Preview {
	NavigationStack {
		UserStarredProjectsLoader(username: "felix-schindler")
	}
}
