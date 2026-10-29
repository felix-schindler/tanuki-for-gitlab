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
	private var tree: Result<RepoTreeQuery.Data.Project.Repository.Tree, Error>? = nil

	@State
	private var branches: [Branch]? = nil

	init(projectId: Int, fullPath: String, refName: String, folderPath: String? = nil) {
		self.projectId = projectId
		self.fullPath = fullPath
		self.refName = refName
		self.folderPath = folderPath
	}

	private func loadTree() {
		let ref: GraphQLNullable<String>
		let path: GraphQLNullable<String>

		ref = .some(refName)

		if let filePath = self.folderPath {
			path = .some(filePath)
		} else {
			path = .none
		}

		do {
			let responses = try Network.shared.apollo.fetch(
				query: RepoTreeQuery(
					fullPath: self.fullPath,
					ref: ref,
					path: path
				),
				cachePolicy: .cacheAndNetwork
			)

			Task {
				for try await response in responses {
					if let tree = response.data?.project?.repository?.tree {
						self.tree = .success(tree)
					} else if let errors = response.errors {
						for error in errors {
							Notify.status(.error, error.localizedDescription)
						}
					}
				}
			}
		} catch let error {
			Notify.status(.error, error.localizedDescription)
		}
	}

	private func reloadTree() async {
		let ref: GraphQLNullable<String>
		let path: GraphQLNullable<String>

		ref = .some(refName)

		if let filePath = self.folderPath {
			path = .some(filePath)
		} else {
			path = .none
		}

		do {
			let response = try await Network.shared.apollo.fetch(
				query: RepoTreeQuery(
					fullPath: self.fullPath,
					ref: ref,
					path: path
				),
				cachePolicy: .networkOnly
			)

			if let tree = response.data?.project?.repository?.tree {
				self.tree = .success(tree)
			}

			Notify.status(.success)
		} catch let error {
			self.tree = .failure(error)
			Notify.status(.error)
		}
	}

	private func loadBranches() async {
		do {
			self.branches = try await API.get(
				type: [Branch].self,
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
							.onChange(of: refName) {
								loadTree()
							}
						}
					}
				}
			}

			Section("Tree") {
				if let tree {
					switch tree {
					case .success(let tree):
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
											Label(folder.name, lucide: .folder)
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
											Label(file.name, lucide: .fileText)
										}
									)
								}
							}
						}
					case .failure(let error):
						FailedView(error)
					}
				} else {
					LoadingView("Loading file tree", lucide: .folder)
				}
			}
		}.task {
			await MainActor.run { loadTree() }
			await loadBranches()
		}.refreshable {
			await reloadTree()
			if folderPath == nil {
				await loadBranches()
			}
		}.toolbar {
			NavigationLink(
				destination: NewFileView(
					projectId: projectId, refName: refName, folderPath: folderPath)
			) {
				Label("New file", lucide: .plus)
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
