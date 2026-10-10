//
//  SmallGroupView.swift
//  Tanuki
//
//  Created by Felix Schindler on 12.10.25.
//

import SwiftUI

private struct _Group: Group {
	var avatarUrl: String?
	var _name: String?
	var fullPath: String
	var visibility: String?
	var groupMembersCount: Int
	var projectsCount: Int
	var _accessLevel: String?
}

struct SmallGroupView: View {
	public let group: Group

	public var body: some View {
		NavigationLink(
			destination: GroupLoader(fullPath: group.fullPath),
			label: {
				HStack {
					if let url = URL.fromAvatar(group.avatarUrl) {
						AvatarImage(url, size: .medium)
					}

					VStack(alignment: .leading) {
						HStack {
							if let groupName = group._name?.emojized(), groupName.isNotEmpty {
								Text(groupName)
							} else {
								Text(group.fullPath)
							}
                            if let visibility = group.visibility {
                                VisibilityIcon(visibility)
                            }
						}

						HStack(spacing: 10) {
							Label(
								String(group.groupMembersCount), lucide: .users,
								size: 17)

							Label(
								String(group.projectsCount), lucide: .layers,
								size: 17)
						}.font(.footnote)
					}

					if let accessLevel = group._accessLevel {
						Spacer()
						PillView(accessLevel.replacing("_", with: " ").capitalized)
							.font(.footnote)
					}
				}
			}
		)
	}
}

#Preview {
	NavigationStack {
		List {
			SmallGroupView(group: _Group(fullPath: "gitlab-org", groupMembersCount: 1, projectsCount: 1))
			SmallGroupView(group: _Group(fullPath: "gitlab-org", groupMembersCount: 1, projectsCount: 1))
			SmallGroupView(
				group: _Group(fullPath: "gitlab-org", groupMembersCount: 1, projectsCount: 1, _accessLevel: "No_Access")
			)
		}.navigationTitle("Groups")
	}
}
