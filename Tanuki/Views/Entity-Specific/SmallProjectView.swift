//
//  SmallProjectView.swift
//  Tanuki
//
//  Created by Felix Schindler on 28.02.24.
//

import SwiftUI

struct SmallProjectView: View {
	private var project: SmallProject
	private let avatarSize: AvatarSize

	init(_ project: SmallProject, avatarSize: AvatarSize = .small) {
		self.project = project
		self.avatarSize = avatarSize
	}

	public var body: some View {
		NavigationLink(
			destination: ProjectLoader(fullPath: project.fullPath),
			label: {
				HStack {
					if let url = URL.fromAvatar(project.avatarUrl) {
						AvatarImage(url, size: avatarSize)
					}
					Text(project.nameWithNamespace)
					Spacer()
					if project.archived == true {
						LucideLabelIcon(.archive)
							.help("Archived")
							.accessibilityLabel("Archived")
					} else if let visibility = project.visibility {
						VisibilityIcon(visibility)
					}
				}
			})
	}
}
