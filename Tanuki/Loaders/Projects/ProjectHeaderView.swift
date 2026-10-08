//
//  ProjectHeaderView.swift
//  Tanuki
//
//  Created by Felix Schindler on 10.09.25.
//

import Charts
import GitLabAPI
import SwiftUI

struct ProjectHeaderView: View {
	private let project: ProjectQuery.Data.Project

	init(_ project: ProjectQuery.Data.Project) {
		self.project = project
	}

	private func star() async {
		do {
			_ = try await Network.shared.apollo.perform(
				mutation: StarProjectMutation(projectId: project.id, starred: true))
			Notify.status(.success, "Project starred", systemImage: "star")
		} catch let error {
			Notify.status(.error, "Starring project failed", error.localizedDescription, systemImage: "xmark")
		}
	}

	private func fork() async {
		guard let id = project.id.toIntId() else {
			Notify.status(.error, "Forking project failed", systemImage: "xmark")
			return
		}
		do {
			_ = try await API.req(
				type: RestAPIProject.self, method: .post,
				endpoint: "projects/\(id)/fork")
			Notify.status(.success, "Project forked", systemImage: "tuningfork")
		} catch let error {
			Notify.status(.error, "Forking project failed", error.localizedDescription, systemImage: "xmark")
		}
	}

	public var body: some View {
		VStack(alignment: .leading) {
			HStack {
				if let avatarUrl = URL.fromAvatar(project.avatarUrl) {
					AvatarImage(avatarUrl, size: .medium)
				}
				Text(project.name.emojized())
					.font(.title)
					.fontWeight(.bold)
				Spacer()
				if let visibility = project.visibility {
					VisibilityIcon(visibility)
				}
			}

			if let description = project.description, description.isNotEmpty {
				Markdown(description)
			}

			HStack {
				if let topics = project.topics, topics.isNotEmpty {
					HStack(spacing: 5) {
						Label("Tags", systemImage: "tag")
							.labelStyle(.iconOnly)
						ScrollView(.horizontal) {
							HStack {
								ForEach(project.topics!, id: \.self) { topic in
									PillView(topic)
								}
							}
						}
					}
				}
			}.font(.footnote)

			ScrollView(.horizontal) {
				HStack {
					if let repositorySize = project.statistics?.repositorySize {
						PillView(ByteFormatter.shared.format(repositorySize))
					}

					if let createdAt = project.createdAt {
						PillView(Date.fromToString(createdAt, dateStyle: .short))
					}
				}
			}.font(.footnote)

			ScrollView(.horizontal) {
				HStack {
					if let namespace = project.namespace {
						if namespace.id.contains("UserNamespace") {
							NavigationLink(
								destination: UserLoader(username: namespace.fullPath),
								label: {
									Label(
										namespace.name,
										systemImage: "person"
									)
								}
							)
							.tint(.accentColor)
							.buttonStyle(.borderedProminent)
						} else if namespace.id.contains("Group") {
							NavigationLink(
								destination: GroupLoader(fullPath: namespace.fullPath),
								label: {
									Label(
										namespace.name,
										systemImage: "scale.3d"
									)
								}
							)
							.tint(.accentColor)
							.buttonStyle(.borderedProminent)
						} else {
							PillView(namespace.name)
						}
					}

					AsyncButton(
						String(project.starCount),
						systemImage: "star"
					) {
						await star()
					}
					.tint(.accentColor)
					.buttonStyle(.bordered)

					if project.userPermissions.forkProject {
						AsyncButton(
							String(project.forksCount),
							systemImage: "tuningfork"
						) {
							await fork()
						}
						.tint(.accentColor)
						.buttonStyle(.bordered)
					} else {
						PillView(
							String(project.forksCount),
							icon: "tuningfork"
						)
					}
				}
				.tint(.primary)
				.buttonStyle(.bordered)
				.controlSize(.small)
			}

			if let languages = project.languages,
				languages.isNotEmpty
			{
				Chart {
					ForEach(languages, id: \.self) {
						language in
						BarMark(
							x: .value(
								"Percent", language.share ?? 1)
						).foregroundStyle(
							by: .value("Language", language.name)
						)
					}
				}
				.chartXAxis(.hidden)
				.chartForegroundStyleScale(
					range: languages.map {
						Color(hex: $0.color) ?? .accentColor
					}
				)
				.chartPlotStyle { plotArea in
					plotArea.frame(height: 10)
				}
			}
		}
	}
}
