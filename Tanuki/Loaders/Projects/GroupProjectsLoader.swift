//
//  GroupProjectsLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 30.10.21.
//  Rewritten by Felix Schindler on 29.02.24.
//

import GitLabAPI
import SwiftUI

struct GroupProjectsLoader: View {
	private let fullPath: String

	@State
	private var projects: Result<[GroupProjectsQuery.Data.Group.Projects.Node?], Error>? = nil

	init(fullPath: String) {
		self.fullPath = fullPath
	}

	private func loadProjects() {
		do {
			let responses = try Network.shared.apollo.fetch(
				query: GroupProjectsQuery(fullPath: self.fullPath),
				cachePolicy: .cacheAndNetwork
			)

			Task {
				for try await response in responses {
					if let projects = response.data?.group?.projects.nodes {
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
				query: GroupProjectsQuery(fullPath: self.fullPath),
				cachePolicy: .networkOnly
			)

			if let projects = response.data?.group?.projects.nodes {
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
						NoContentView(
							"The group \(self.fullPath) doesn't have any projects",
							lucide: .layers
						)
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
				LoadingView("Loading Projects", lucide: .layers)
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
		GroupProjectsLoader(fullPath: "gitlab-org")
	}
}
