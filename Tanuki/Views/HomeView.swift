//
//  Home.swift
//  Tanuki
//
//  Created by Felix Schindler on 27.02.24.
//

import GitLabAPI
import SwiftUI
import UIKit

struct HomeView: View {
	@State
	private var starredProjects: Result<[SmallProject?], Error>?

	@State
	private var path = NavigationPath()

	private func loadStarredProjects() {
		do {
			let responses = try Network.shared.apollo.fetch(
				query: CurrentUserStarredProjectsQuery(), cachePolicy: .cacheAndNetwork)

			Task {
				for try await response in responses {
					if let projects = response.data?.currentUser?.starredProjects?.nodes {
						starredProjects = .success(projects)
					} else if let errors = response.errors {
						for error in errors {
							Notify.status(.error, error.localizedDescription)
						}
					}
				}
			}
		} catch let error {
			starredProjects = .failure(error)
			Notify.status(.error)
		}
	}

	private func reloadStarredProjects() async {
		do {
			let response = try await Network.shared.apollo.fetch(
				query: CurrentUserStarredProjectsQuery(), cachePolicy: .networkOnly)

			if let projects = response.data?.currentUser?.starredProjects?.nodes {
				starredProjects = .success(projects)
			}

			Notify.status(.success)
		} catch let error {
			starredProjects = .failure(error)
			Notify.status(.error)
		}
	}

	private func jumpToClipboard() {
		let pasted =
			UIPasteboard.general.string
			?? UIPasteboard.general.url?.absoluteString

		let host = API.host
		var diagnostics = JumpDiagnostics(raw: pasted ?? "", host: host)

		if let pasted, pasted.isNotEmpty {
			do {
				diagnostics.target = try JumpURL.parse(pasted, host: host)
			} catch let error as JumpURLError {
				diagnostics.error = error
			} catch {
				diagnostics.error = .notALink(raw: pasted)
			}
		} else {
			diagnostics.error = .emptyClipboard
		}

		guard let target = diagnostics.target else {
			Notify.status(
				.warning, diagnostics.summary, diagnostics.error?.message,
				systemImage: "exclamationmark.triangle")
			return
		}

		path.append(target)
	}

	public var body: some View {
		NavigationStack(path: $path) {
			list
				.navigationDestination(for: JumpTarget.self) { target in
					switch target {
					case .entity(let fullPath):
						EntityLoader(fullPath: fullPath)
					case .issue(let fullPath, let iid):
						IssueLoader(fullPath: fullPath, iid: iid)
					case .mergeRequest(let fullPath, let iid):
						MergeRequestLoader(fullPath: fullPath, iid: iid)
					case .route(let fullPath, let route):
						EntityLoader(fullPath: fullPath, route: route)
					}
				}
		}
	}

	private var list: some View {
		List {
			Section("Your work") {
				NavigationLink(
					destination: UserIssuesLoader(),
					label: {
						Label("Issues", lucide: .circleDot, color: .green)
					})

				DisclosureGroup(
					content: {
						NavigationLink(
							"Assigned", destination: UserMergeLoader(.assgined))
						NavigationLink(
							"Authored", destination: UserMergeLoader(.authored))
						NavigationLink(
							"Review requested",
							destination: UserMergeLoader(.reviewRequested))
					},
					label: {
						Label("Merge Requests", lucide: .gitPullRequest, color: .blue)
					})

				NavigationLink(
					destination: ProjectsLoader(membership: true),
					label: {
						Label("Projects", lucide: .layers, color: .gray)
					}
				)

				NavigationLink(
					destination: UserSnippetsLoader(),
					label: {
						Label("Snippets", lucide: .scissors, color: .purple)
					}
				)

				NavigationLink(
					destination: GroupsLoader(allAvailable: false),
					label: {
						Label("Groups", lucide: .building, color: .red)
					}
				)
			}

			Section("Starred projects") {
				if let starredProjects {
					switch starredProjects {
					case .success(let projects):
						if projects.isEmpty {
							NoContentView(
								"There are no starred projects",
								lucide: .star)
						} else {
							ForEach(projects, id: \.?.fullPath) { maybeProject in
								if let project = maybeProject {
									SmallProjectView(project)
								}
							}
						}
					case .failure(let error):
						FailedView(error)
							.frame(maxWidth: .infinity, minHeight: 100)
					}
				} else {
					LoadingView("Loading starred Projects", lucide: .star, color: .yellow)
				}
			}
		}.task {
			loadStarredProjects()
		}.refreshable {
			await reloadStarredProjects()
		}.toolbar {
			ToolbarItem(placement: .topBarLeading) {
				Button("Jump", lucide: .clipboardPaste) {
					jumpToClipboard()
				}.tint(.accentColor)
			}
			ToolbarItemGroup(placement: .topBarTrailing) {
				NavigationLink(destination: EventsLoader()) {
					Label("Activity", lucide: .bell)
				}.tint(.accentColor)
				NavigationLink(destination: NewProjectView()) {
					Label("New project", lucide: .plus)
				}.tint(.accentColor)
			}
		}
		.listStyle(.sidebar)
		.headerProminence(.increased)
		.navigationTitle("Home")
	}
}

#Preview {
	NavigationStack {
		HomeView()
	}
}
