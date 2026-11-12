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

					if let groupName = group._name?.emojized(), groupName.isNotEmpty {
						Text(groupName)
					} else {
						Text(group.fullPath)
					}

					Spacer()
					if let accessLevel = group._accessLevel {
						PillView(accessLevel.replacingOccurrences(of: "_", with: " ").capitalized)
							.font(.footnote)
					}
					if let visibility = group.visibility {
						VisibilityIcon(visibility)
					}
				}
			}
		)
	}
}

#Preview {
	NavigationStack {
		List {
			SmallGroupView(group: _Group(fullPath: "gitlab-org"))
			SmallGroupView(group: _Group(fullPath: "gitlab-org"))
			SmallGroupView(
				group: _Group(fullPath: "gitlab-org", _accessLevel: "No_Access")
			)
		}.navigationTitle("Groups")
	}
}
