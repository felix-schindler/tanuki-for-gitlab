//
//  ExploreView.swift
//  Tanuki
//
//  Created by Felix Schindler on 20.09.25.
//

import SwiftUI

struct ExploreView: View {
	public var body: some View {
		List {
			NavigationLink(
				destination: ProjectsLoader(),
				label: {
					Label(
						title: {
							Text("Projects")
						},
						icon: {
							Image(systemName: Icons.projects.rawValue)
								.foregroundStyle(.gray)
						}
					)
				}
			)
			NavigationLink(
				destination: GroupsLoader(),
				label: {
					Label(
						title: {
							Text("Groups")
						},
						icon: {
							Image(systemName: Icons.groups.rawValue)
								.foregroundStyle(.red)
						}
					)
				})
			NavigationLink(
				destination: UsersLoader(),
				label: {
					Label(
						title: {
							Text("Users")
						},
						icon: {
							Image(systemName: Icons.members.rawValue)
								.foregroundStyle(.cyan)
						}
					)
				})
		}.navigationTitle("Explore")
	}
}

#Preview {
	NavigationStack {
		ExploreView()
	}
}
