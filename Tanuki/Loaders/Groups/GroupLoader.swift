//
//  GroupLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 29.02.24.
//

import GitLabAPI
import SwiftUI

struct GroupLoader: View {
	private let fullPath: String

	@State
	private var group: Result<GroupQuery.Data.Group, Error>? = nil

	@State
	private var navigationActive = false

	@State
	private var createSubgroup = false

	init(fullPath: String) {
		self.fullPath = fullPath
	}

	private func loadGroup() {
		do {
			let responses = try Network.shared.apollo.fetch(
				query: GroupQuery(fullPath: self.fullPath), cachePolicy: .cacheAndNetwork)

			Task {
				for try await response in responses {
					if let group = response.data?.group {
						self.group = .success(group)
					} else if let errors = response.errors {
						for error in errors {
							Notify.status(.error, error.localizedDescription)
						}
					}
				}
			}
		} catch let error {
			self.group = .failure(error)
			Notify.status(.error)
		}
	}

	private func reloadGroup() async {
		do {
			let response = try await Network.shared.apollo.fetch(
				query: GroupQuery(fullPath: self.fullPath), cachePolicy: .networkOnly)

			if let group = response.data?.group {
				self.group = .success(group)
			}

			Notify.status(.success)
		} catch let error {
			self.group = .failure(error)
			Notify.status(.error)
		}
	}

	private func requestAccess(_ groupId: Int) async {
		do {
			_ = try await API.req(type: UserSmall.self, method: .post, endpoint: "groups/\(groupId)/access_requests")
			Notify.status(.success, "Access request sent", systemImage: "checkmark")
		} catch let error {
			Notify.status(.error, "Access request failed", error.localizedDescription, systemImage: "xmark")
		}
	}

	public var body: some View {
		List {
			if let group {
				switch group {
				case .success(let group):
					VStack(alignment: .leading) {
						HStack {
							if let avatarUrl = URL.fromAvatar(group.avatarUrl) {
								AvatarImage(avatarUrl, size: .medium)
							}
							if let name = group.name?.emojized(), name.isNotEmpty {
								Text(name)
									.font(.title)
									.fontWeight(.bold)
							}
							if let visibility = group.visibility {
                                Spacer()
								VisibilityIcon(visibility)
							}
						}

						ScrollView(.horizontal) {
							HStack {
								PillView("\(group.groupMembersCount)", icon: .users)

								if let parent = group.parent {
									NavigationLink(
										destination: GroupLoader(fullPath: parent.fullPath),
										label: {
                                            Label(parent.name ?? parent.fullPath, lucide: .building)
										}
                                    ).buttonStyle(.bordered)
								}

								if group.name != group.fullName {
									PillView(group.fullName ?? group.path)
								}
							}.font(.footnote)
						}

						if let description = group.description, description.isNotEmpty {
							Markdown(description)
						}
					}

					Section {
						HStack {
							NavigationLink(
								destination: GroupProjectsLoader(
									fullPath: self.fullPath
								),
								label: {
									Label(
										title: {
											HStack {
												Text("Projects")
												Spacer()
												Text("\(group.projectsCount)")
											}
										},
										icon: {
											LucideLabelIcon(.gift, color: .gray)
										}
									)
								}
							)
						}
						HStack {
							NavigationLink(
								destination: GroupsLoader(parentPath: self.fullPath),
								label: {
									Label(
										title: {
											HStack {
												Text("Descendant groups")
												Spacer()
												Text("\(group.descendantGroupsCount)")
											}
										},
										icon: {
											LucideLabelIcon(.building, color: .red)
										}
									)
								})
						}

						DisclosureGroup(
							content: {
								if let groupId = group.id?.toIntId() {
									NavigationLink(
										"Members",
										destination: MembersLoader(
											fullPath: self.fullPath,
											id: groupId,
											type: .group
										)
									)
									NavigationLink(
										"Labels",
										destination: LabelsLoader(
											fullPath: self.fullPath,
											id: groupId,
											queryType: .group
										)
									)
									NavigationLink(
										destination: EditGroupView(
											groupId: groupId,
											name: group.name ?? group.path,
											description: group.description,
											visibility: group.visibility ?? "private"
										),
										label: {
											Text("Settings")
										}
									)
								}
								NavigationLink(
									"Timelogs",
									destination: TimelogsLoader(
										fullPath: self.fullPath,
										queryType: .group
									)
								)
								NavigationLink(
									"Custom emojis",
									destination: CustomEmojisLoader(
										fullPath: self.fullPath
									))
							},
							label: {
								Label("Manage", lucide: .users)
							}
						)

						DisclosureGroup(
							content: {
								NavigationLink(
									"Issues",
									destination: GroupIssuesLoader(fullPath: self.fullPath)
								)
								if let groupId = group.id?.toIntId() {
									NavigationLink(
										"Milestones",
										destination: MilestonesLoader(
											fullPath: self.fullPath,
											id: groupId,
											queryType: .group
										)
									)
								}
							},
							label: {
								Label("Plan", lucide: .calendarCheck)
							}
						)

						DisclosureGroup(
							content: {
								NavigationLink(
									"Merge Requests",
									destination: GroupMergeLoader(fullPath: self.fullPath))
							},
							label: {
								Label("Code", lucide: .codeXml)
							}
						)
					}.navigationTitle(group.path)
				case .failure(let error):
					FailedView(error.localizedDescription, icon: .building)
				}
			} else {
				LoadingView("Loading Group \(self.fullPath)", lucide: .building)
			}
		}.task {
			loadGroup()
		}.refreshable {
			await reloadGroup()
		}.toolbar {
			if let group, case .success(let group) = group {
				HStack {
					if let url = URL(string: group.webUrl) {
						ShareButton(url)
					}

					if group.userPermissions.createProjects || group.requestAccessEnabled ?? false {
						Menu("More", lucide: .ellipsis) {
							if group.userPermissions.createProjects {
								Button("Create project", lucide: .plus) {
									navigationActive = true
								}
							}

							Button("Create subgroup", lucide: .building) {
								createSubgroup = true
							}

							if group.requestAccessEnabled ?? false,
								let groupId = group.id?.toIntId()
							{
								AsyncButton(
									"Request access",
									lucide: .userPlus
								) {
									await requestAccess(groupId)
								}
							}
						}
					}
				}
			}
		}.navigationDestination(isPresented: $navigationActive) {
			if let group, case .success(let group) = group,
				let groupId = group.id?.toIntId()
			{
				NewProjectView(groupId)
			} else {
				FailedView("Form couldn't be opened because the namespace ID is not defined")
			}
		}.navigationDestination(isPresented: $createSubgroup) {
			if let group, case .success(let group) = group,
				let groupId = group.id?.toIntId()
			{
				NewGroupView(parentId: groupId)
			} else {
				FailedView("Form couldn't be opened because the namespace ID is not defined")
			}
		}
		.navigationTitle(fullPath)
		.navigationBarTitleDisplayMode(.inline)
	}
}

#Preview {
	NavigationStack {
		GroupLoader(fullPath: "gitlab-org/production-engineering")
	}
}
