//
//  BranchesLoader.swift
//  GitLab
//
//  Created by Felix Schindler on 02.11.21.
//

import SwiftUI

struct BranchesLoader: View {
	private var projectId: Int

	@State
	private var branches: Result<[Branch], Error>? = nil

	init(_ projectId: Int) {
		self.projectId = projectId
	}

	private func loadBranches() async {
		do {
			let temp = try await API.get(
				type: [Branch].self, endpoint: "projects/\(projectId)/repository/branches")

			self.branches = .success(temp)
		} catch let error {
			self.branches = .failure(error)
			Notify.status(.error)
		}
	}

	public var body: some View {
		List {
			if let branches {
				switch branches {
				case .success(let branches):
					if branches.isEmpty {
						NoContentView(
							"You'll see your branches after you pushed them",
							lucide: .gitBranch
						)
					} else {
						ForEach(branches, id: \.name) { branch in
							VStack(alignment: .leading) {
								HStack {
									if branch.protected {
										LucideLabelIcon(.lock)
									}
									Text(branch.name.emojized())
										.font(.headline)
								}

								ScrollView(.horizontal) {
									HStack {
										PillView(branch.commit.shortId)
											.font(.system(.footnote, design: .monospaced))
										PillView(branch.commit.authoredDate.toString(), icon: "clock")
									}
								}.font(.footnote)
								Text(branch.commit.title.emojized())
									.font(.footnote)
							}
						}
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView(
					"Loading Branches",
					lucide: .gitBranch
				)
			}
		}.task {
			await loadBranches()
		}.refreshable {
			await loadBranches()
		}.toolbar {
			NavigationLink(destination: NewBranchView(projectId: projectId)) {
				Label("New branch", lucide: .plus)
			}.tint(.accentColor)
		}.navigationTitle("Branches")
	}
}

#Preview {
	NavigationStack {
		BranchesLoader(33_025_310)
	}
}
