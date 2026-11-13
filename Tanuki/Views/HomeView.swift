//
//  Home.swift
//  Tanuki
//
//  Created by Felix Schindler on 27.02.24.
//

import GitLabAPI
import SwiftUI
import UIKit

private enum HomeRoute: Hashable {
	case issues
	case mergeRequests(UserMergeRequestType)
	case projects
	case snippets
	case groups
	case project(fullPath: String)
	case jump(JumpTarget)
}

struct HomeView: View {
	@State
	private var starredProjects: Result<[SmallProject?], Error>?

	@State
	private var versionWarning: String?

	@State
	private var selection: HomeRoute?

	@State
	private var preferredColumn = NavigationSplitViewColumn.sidebar

	@Environment(\.horizontalSizeClass)
	private var horizontalSizeClass

	private func checkVersion() async {
		guard let version = try? await API.get(type: RestAPIVersion.self, endpoint: "version"),
			VersionGate.compareVersions(version.version, VersionGate.minimumRequiredVersion)
				== .orderedAscending,
			VersionGate.shouldShowVersionWarning(
				for: API.host, serverVersion: version.version)
		else {
			versionWarning = nil
			return
		}

		versionWarning = version.version
	}

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

		selection = .jump(target)
		preferredColumn = .detail
	}

	public var body: some View {
		NavigationSplitView(preferredCompactColumn: $preferredColumn) {
			list
				.toolbar {
					if horizontalSizeClass != .regular {
						toolbar
					}
				}
		} detail: {
			// Rebuild for a new selection so the detail does not keep the previous item's state.
			NavigationStack {
				if let selection {
					destination(selection)
				} else {
					placeholder
				}
			}
			.id(selection)
			.toolbar {
				if horizontalSizeClass == .regular {
					toolbar
				}
			}
		}
	}

	@ToolbarContentBuilder
	private var toolbar: some ToolbarContent {
		ToolbarItem(placement: .topBarLeading) {
			Button("Jump", systemImage: "arrow.right.page.on.clipboard") {
				jumpToClipboard()
			}.tint(.accentColor)
		}
		ToolbarItemGroup(placement: .topBarTrailing) {
			NavigationLink(destination: EventsLoader()) {
				Label("Activity", systemImage: Icons.events.rawValue)
			}.tint(.accentColor)
			NavigationLink(destination: NewProjectView()) {
				Label("New project", systemImage: "plus")
			}.tint(.accentColor)
		}
	}

	@ViewBuilder
	private func destination(_ route: HomeRoute) -> some View {
		switch route {
		case .issues:
			UserIssuesLoader()
		case .mergeRequests(let type):
			UserMergeLoader(type)
		case .projects:
			ProjectsLoader(membership: true)
		case .snippets:
			UserSnippetsLoader()
		case .groups:
			GroupsLoader(allAvailable: false)
		case .project(let fullPath):
			ProjectLoader(fullPath: fullPath)
		case .jump(let target):
			jumpDestination(target)
		}
	}

	@ViewBuilder
	private func jumpDestination(_ target: JumpTarget) -> some View {
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

	private var placeholder: some View {
		VStack(spacing: 12) {
			Image(systemName: Icons.home.rawValue)
				.font(.system(size: 44))
				.foregroundStyle(.secondary)
			Text("Tanuki")
				.font(.title2.bold())
			Text("Choose an item on the left.")
				.foregroundStyle(.secondary)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}

	private var list: some View {
		List(selection: $selection) {
			if let versionWarning {
				Section {
					Label(
						"This instance runs GitLab \(versionWarning). Tanuki needs GitLab \(VersionGate.minimumRequiredVersion) or later — some features may not work.",
						systemImage: "exclamationmark.triangle.fill"
					)
					.swipeActions {
						Button("Acknowledge", systemImage: "xmark") {
							VersionGate.acknowledgeVersionWarning(
								for: API.host, serverVersion: versionWarning)
							self.versionWarning = nil
						}
					}
				}
			}

			Section("Your work") {
				NavigationLink(
					value: HomeRoute.issues,
					label: {
						Label(
							title: {
								Text("Issues")
							},
							icon: {
								Image(systemName: Icons.issues.rawValue)
									.foregroundStyle(.green)
							})
					})

				DisclosureGroup(
					content: {
						NavigationLink(
							"Assigned", value: HomeRoute.mergeRequests(.assgined))
						NavigationLink(
							"Authored", value: HomeRoute.mergeRequests(.authored))
						NavigationLink(
							"Review requested",
							value: HomeRoute.mergeRequests(.reviewRequested))
					},
					label: {
						Label(
							title: {
								Text("Merge Requests")
							},
							icon: {
								Image(Images.mergeRequest.rawValue)
									.foregroundStyle(.blue)
							})
					})

				NavigationLink(
					value: HomeRoute.projects,
					label: {
						Label(
							title: {
								Text("Projects")
							},
							icon: {
								Image(systemName: Icons.projects.rawValue)
									.foregroundStyle(.gray)
							})
					}
				)

				NavigationLink(
					value: HomeRoute.snippets,
					label: {
						Label(
							title: {
								Text("Snippets")
							},
							icon: {
								Image(systemName: Icons.snippets.rawValue)
									.foregroundStyle(.purple)
							})
					}
				)

				NavigationLink(
					value: HomeRoute.groups,
					label: {
						Label(
							title: {
								Text("Groups")
							},
							icon: {
								Image(systemName: Icons.groups.rawValue)
									.foregroundStyle(.red)
							})
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
								systemImage: "star.square.on.square.fill")
						} else {
							ForEach(projects, id: \.?.fullPath) { maybeProject in
								if let project = maybeProject {
									NavigationLink(
										value: HomeRoute.project(fullPath: project.fullPath),
										label: {
											SmallProjectLabel(project)
										})
								}
							}
						}
					case .failure(let error):
						FailedView(error)
							.frame(maxWidth: .infinity, minHeight: 100)
					}
				} else {
					LoadingView("Loading starred Projects", systemImage: Icons.star.rawValue, color: .yellow)
				}
			}
		}.task {
			loadStarredProjects()
			await checkVersion()
		}.refreshable {
			await reloadStarredProjects()
			await checkVersion()
		}
		.listStyle(.sidebar)
		.headerProminence(.increased)
		.navigationTitle("Home")
	}
}

#Preview {
	HomeView()
}
