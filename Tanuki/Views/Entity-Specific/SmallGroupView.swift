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
							if let visibility = group.visibility {
								VisibilityIcon(visibility)
							}
							if let groupName = group._name?.emojized(), groupName.isNotEmpty {
								Text(groupName)
							} else {
								Text(group.fullPath)
							}
						}

						ScrollView(.horizontal) {
							HStack {
								PillView(String(group.groupMembersCount), icon: "person.2")
								PillView(String(group.projectsCount), icon: "app.gift.fill")
							}
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
