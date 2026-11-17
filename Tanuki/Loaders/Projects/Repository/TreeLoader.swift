//
//  TreeLoader.swift
//  GitLab
//
//  Created by Felix Schindler on 23.01.22.
//

import GitLabAPI
import SwiftUI

struct TreeLoader: View {
	// MARK: - Initialized
	private let projectId: Int
	private let fullPath: String

	private let folderPath: String?

	@State
	private var refName: String

	// MARK: - Loaded by API
	@State
	private var loader = ApolloLoader<RepoTreeQuery, RepoTreeQuery.Data.Project.Repository.Tree> {
		$0.project?.repository?.tree
	}

	@State
	private var branches: [Branch]? = nil

	init(projectId: Int, fullPath: String, refName: String, folderPath: String? = nil) {
		self.projectId = projectId
		self.fullPath = fullPath
		self.refName = refName
		self.folderPath = folderPath
	}

	private var query: RepoTreeQuery {
		RepoTreeQuery(
			fullPath: fullPath,
			ref: .some(refName),
			path: GraphFilter.toFilter(folderPath)
		)
	}

	private func loadBranches() async {
		do {
			self.branches = try await API.allPages(
				[Branch].self,
				endpoint: "projects/\(self.projectId)/repository/branches"
			)
		} catch let error {
			Notify.status(.error, error.localizedDescription)
		}
	}

	public var body: some View {
		List {
			if self.folderPath == nil {
				Section {
					if let branches {
						HStack {
							Picker("Branch", selection: $refName) {
								ForEach(branches, id: \.name) { branch in
									Text(branch.name).tag(branch.name)
								}
							}
							.pickerStyle(.menu)

						}
					}
				}
			}

			Section("Tree") {
				let state = loader.state
				if state.isInitialLoading {
					LoadingView("Loading file tree", systemImage: "folder")
				} else if state.isColdFailure, let error = state.error {
					FailedView(error)
				} else if let tree = state.value {
					if let folders = tree.trees.nodes {
						ForEach(folders, id: \.?.path) { maybeFolder in
							if let folder = maybeFolder {
								NavigationLink(
									destination: TreeLoader(
										projectId: self.projectId,
										fullPath: self.fullPath,
										refName: self.refName,
										folderPath: folder.path
									),
									label: {
										Label(folder.name, systemImage: "folder")
									}
								)
							}
						}
					}

					if let files = tree.blobs.nodes {
						ForEach(files, id: \.?.path) { maybeFile in
							if let file = maybeFile {
								NavigationLink(
									destination: FileLoader(
										id: projectId,
										filePath: file.path,
										refName: self.refName
									),
									label: {
										Label(file.name, systemImage: Icons.files.rawValue)
									}
								)
							}
						}
					}
				}
			}
		}.task(id: refName) {
			await loader.load(query)
		}.task {
			await loadBranches()
		}.refreshable {
			await loader.reload(query)
			if folderPath == nil {
				await loadBranches()
			}
		}.toolbar {
			NavigationLink(
				destination: NewFileView(
					projectId: projectId, refName: refName, folderPath: folderPath)
			) {
				Label("New file", systemImage: "plus")
			}.tint(.accentColor)
		}.navigationTitle(folderPath ?? "Files")
	}
}

#Preview {
	NavigationStack {
		TreeLoader(
			projectId: 33_025_310,
			fullPath: "felix-schindler/gitlab-ios",
			refName: "main"
		)
	}
}
