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
					Label("Projects", lucide: .layers, color: .gray)
				}
			)
			NavigationLink(
				destination: GroupsLoader(),
				label: {
					Label("Groups", lucide: .building, color: .red)
				})
			NavigationLink(
				destination: UsersLoader(),
				label: {
					Label("Users", lucide: .users, color: .cyan)
				})
		}.navigationTitle("Explore")
	}
}

#Preview {
	NavigationStack {
		ExploreView()
	}
}
