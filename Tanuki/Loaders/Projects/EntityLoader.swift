//
//  EntityLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 07.10.26.
//

import GitLabAPI
import SwiftUI

/// Resolves a bare `host/namespace/path` link to a project, group or user, and any
/// `/-/…` sub-page to the matching project/group screen. GitLab can't tell a project
/// path from a group (or user) path without a lookup, so this asks for all three at once.
struct EntityLoader: View {
	private let fullPath: String
	private let route: JumpRoute?

	private enum Entity {
		case project(id: Int, rootRef: String?)
		case group(id: Int)
		case user(username: String)
	}

	@State
	private var loader: ApolloLoader<EntityIdQuery, Entity>

	init(fullPath: String, route: JumpRoute? = nil) {
		self.fullPath = fullPath
		self.route = route
		_loader = State(
			initialValue: ApolloLoader(extract: { data in
				if let project = data.project, let id = project.id.toIntId() {
					return .project(id: id, rootRef: project.repository?.rootRef)
				}
				if let group = data.group, let id = group.id?.toIntId() {
					return .group(id: id)
				}
				if route == nil, !fullPath.contains("/"), data.user != nil {
					return .user(username: fullPath)
				}
				return nil
			}))
	}

	var body: some View {
		let state = loader.state

		SwiftUI.Group {
			if state.isInitialLoading {
				LoadingView("Loading \(fullPath)", systemImage: "magnifyingglass")
			} else if state.isColdFailure, let error = state.error {
				FailedView(error)
			} else if let entity = state.value {
				destination(for: entity)
			}
		}
		.task {
			await loader.load(EntityIdQuery(fullPath: fullPath, username: fullPath))
		}
	}

	@ViewBuilder
	private func destination(for entity: Entity) -> some View {
		switch entity {
		case .project(let id, let rootRef):
			projectPage(id: id, rootRef: rootRef)
		case .group(let id):
			groupPage(id: id)
		case .user(let username):
			UserLoader(username: username)
		}
	}

	@ViewBuilder
	private func projectPage(id: Int, rootRef: String?) -> some View {
		if let route {
			switch route {
			case .issues:
				ProjectIssuesLoader(fullPath: fullPath)
			case .mergeRequests:
				ProjectMergeLoader(fullPath: fullPath)
			case .releases:
				ProjectReleasesLoader(fullPath: fullPath, projectId: id)
			case .pipelines:
				ProjectPipelinesLoader(fullPath: fullPath)
			case .labels:
				LabelsLoader(fullPath: fullPath, id: id, queryType: .project)
			case .milestones:
				MilestonesLoader(fullPath: fullPath, id: id, queryType: .project)
			case .members:
				MembersLoader(fullPath: fullPath, id: id, type: .project)
			case .activity:
				EventsLoader(projectId: id)
			case .branches:
				BranchesLoader(id)
			case .tags:
				TagsLoader(id)
			case .commits(let ref):
				CommitsLoader(id, refName: ref ?? rootRef ?? "")
			case .commit(let sha):
				DiffLoader(projectId: id, commitSha: sha)
			case .tree(let ref, let path):
				TreeLoader(
					projectId: id, fullPath: fullPath, refName: ref ?? rootRef ?? "",
					folderPath: path)
			case .blob(let ref, let path):
				FileLoader(id: id, filePath: path, refName: ref ?? rootRef ?? "")
			}
		} else {
			ProjectLoader(fullPath: fullPath)
		}
	}

	@ViewBuilder
	private func groupPage(id: Int) -> some View {
		if let route {
			switch route {
			case .issues:
				GroupIssuesLoader(fullPath: fullPath)
			case .mergeRequests:
				GroupMergeLoader(fullPath: fullPath)
			case .labels:
				LabelsLoader(fullPath: fullPath, id: id, queryType: .group)
			case .milestones:
				MilestonesLoader(fullPath: fullPath, id: id, queryType: .group)
			case .members:
				MembersLoader(fullPath: fullPath, id: id, type: .group)
			default:
				GroupLoader(fullPath: fullPath)
			}
		} else {
			GroupLoader(fullPath: fullPath)
		}
	}
}

#Preview {
	NavigationStack {
		EntityLoader(fullPath: "gitlab-org/gitlab")
	}
}
