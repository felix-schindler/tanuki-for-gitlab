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
/// path from a group (or user) path without a lookup, so this asks, in order.
struct EntityLoader: View {
	private let fullPath: String
	private let route: JumpRoute?

	@State
	private var entity: Result<Entity, Error>?

	private enum Entity {
		case project(id: Int, rootRef: String?)
		case group(id: Int)
		case user(username: String)
	}

	init(fullPath: String, route: JumpRoute? = nil) {
		self.fullPath = fullPath
		self.route = route
	}

	private func resolve() {
		Task {
			if let response = try? await Network.shared.apollo.fetch(
				query: ProjectQuery(fullPath: fullPath), cachePolicy: .networkOnly),
				let project = response.data?.project, let id = project.id.toIntId()
			{
				entity = .success(.project(id: id, rootRef: project.repository?.rootRef))
				return
			}

			if let response = try? await Network.shared.apollo.fetch(
				query: GroupQuery(fullPath: fullPath), cachePolicy: .networkOnly),
				let group = response.data?.group, let id = group.id?.toIntId()
			{
				entity = .success(.group(id: id))
				return
			}

			// Only a bare, single-segment path can be a username.
			if route == nil, !fullPath.contains("/"),
				let response = try? await Network.shared.apollo.fetch(
					query: UserQuery(username: fullPath), cachePolicy: .networkOnly),
				response.data?.user != nil
			{
				entity = .success(.user(username: fullPath))
				return
			}

			entity = .failure(
				ProjectLoadError(
					fullPath: fullPath,
					messages: ["No project, group or user at this path."]))
		}
	}

	var body: some View {
		SwiftUI.Group {
			if let entity {
				switch entity {
				case .success(let entity):
					destination(for: entity)
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading \(fullPath)", lucide: .search)
			}
		}
		.task {
			resolve()
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
