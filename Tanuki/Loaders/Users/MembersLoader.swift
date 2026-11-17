//
//  ProjectMembersLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 04.03.24.
//

import GitLabAPI
import SwiftUI
import TanukiShared

enum MemberType {
	case project,
		group
}

struct MembersLoader: View {
	private let id: Int
	private let fullPath: String
	private let queryType: MemberType

	@State
	private var projectPager = PagedQuery<ProjectMembersQuery, Member>(
		extract: { ($0.project?.projectMembers?.nodes ?? []).compactMap { $0 } },
		key: { $0.id },
		hasNext: { $0.project?.projectMembers?.pageInfo.hasNextPage ?? false },
		endCursor: { $0.project?.projectMembers?.pageInfo.endCursor }
	)

	@State
	private var groupPager = PagedQuery<GroupMembersQuery, Member>(
		extract: { ($0.group?.groupMembers?.nodes ?? []).compactMap { $0 } },
		key: { $0.id },
		hasNext: { $0.group?.groupMembers?.pageInfo.hasNextPage ?? false },
		endCursor: { $0.group?.groupMembers?.pageInfo.endCursor }
	)

	init(fullPath: String, id: Int, type: MemberType) {
		self.fullPath = fullPath
		self.id = id
		self.queryType = type
	}

	private var state: Loadable<[Member]> {
		switch queryType {
		case .project: projectPager.state
		case .group: groupPager.state
		}
	}

	private var hasMore: Bool {
		switch queryType {
		case .project: projectPager.hasMore
		case .group: groupPager.hasMore
		}
	}

	private func load() async {
		switch queryType {
		case .project:
			await projectPager.start(
				ProjectMembersQuery(first: 50, after: .none, fullPath: fullPath),
				setCursor: { $0.after = .some($1) })
		case .group:
			await groupPager.start(
				GroupMembersQuery(first: 50, after: .none, fullPath: fullPath),
				setCursor: { $0.after = .some($1) })
		}
	}

	private func refresh() async {
		switch queryType {
		case .project: await projectPager.refresh()
		case .group: await groupPager.refresh()
		}
	}

	private func loadMore() async {
		switch queryType {
		case .project: await projectPager.loadMore()
		case .group: await groupPager.loadMore()
		}
	}

	public var body: some View {
		LoadableList(
			state,
			hasMore: hasMore,
			emptyMessage: "This project has no members",
			emptySystemImage: Icons.members.rawValue,
			loadingMessage: "Loading Members",
			loadingSystemImage: Icons.members.rawValue,
			onLoadMore: { await loadMore() },
			onRefresh: { await refresh() }
		) { member in
			if let user = member._user {
				NavigationLink(
					destination: UserLoader(
						username: user.username
					),
					label: {
						VStack(alignment: .leading) {
							HStack {
								if let avatarUrl = URL.fromAvatar(
									user.avatarUrl
								) {
									AvatarImage(avatarUrl)
								}
								VStack(
									alignment: .leading
								) {
									Text(user.name)
									Text(
										"@\(user.username)"
									)
									.foregroundStyle(
										.secondary
									)
								}
								if let accessLevel = member
									._accessLevel?
									.lowercased()
									.capitalized
								{
									Spacer()
									PillView(accessLevel)
										.font(.footnote)
								}
							}

							ScrollView(.horizontal) {
								HStack {
									if let author = member._createdBy,
										author.username != user.username
									{
										AuthorView(author)
									}
									if let createdAt = member.createdAt {
										PillView(
											Date.fromToString(createdAt), icon: Icons.clock.rawValue
										)
									}
									if let expiresAt = member.expiresAt {
										PillView(
											"Expires \(Date.fromToString(expiresAt))",
											icon: "alarm"
										)
									}
								}.font(.footnote)
							}
						}
					}
				)
			}
		}.task {
			await load()
		}.toolbar {
			NavigationLink(
				destination: {
					if self.queryType == .project {
						NewMemberView(id: self.id, groupId: 0)
					} else {
						NewMemberView(id: 0, groupId: self.id)
					}
				},
				label: {
					Label("Add new Member", systemImage: "person.badge.plus")
				}
			).tint(.accentColor)
		}.navigationTitle("Members")
	}
}

#Preview {
	NavigationStack {
		MembersLoader(fullPath: "gitlab-org/gitlab", id: 278_964, type: .project)
	}
}
