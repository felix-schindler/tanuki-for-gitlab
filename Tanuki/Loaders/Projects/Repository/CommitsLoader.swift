//
//  Commits.swift
//  GitLab
//
//  Created by Felix Schindler on 02.11.21.
//

import SwiftUI

struct Commit: Codable {
	let id: String
	let shortId: String
	let title: String
	let message: String
	let authorName: String
	let authoredDate: Date
	let webUrl: String
}

struct Branch: Codable {
	let name: String
	let commit: Commit
	let merged: Bool
	let protected: Bool
	let developersCanPush: Bool
	let developersCanMerge: Bool
	let canPush: Bool
}

struct CommitsLoader: View {
	// MARK: - Load config
	/// Project ID
	private var projectId: Int
	/// Branch name
	@State
	private var refName: String

	init(_ projectId: Int, refName: String) {
		self.projectId = projectId
		self.refName = refName
	}

	// MARK: - Load data
	@State
	private var branches: [Branch]? = nil

	@State
	private var commits: Result<[Commit], Error>? = nil

	@State
	private var isLoading = false

	private func loadCommits() async {
		do {
			let temp = try await API.get(
				type: [Commit].self,
				endpoint: "projects/\(projectId)/repository/commits",
				query: ["ref_name": refName]
			)

			self.commits = .success(temp)
		} catch let error {
			self.commits = .failure(error)
			Notify.status(.error)
		}
	}

	private func loadBranches() async {
		do {
			self.branches = try await API.get(
				type: [Branch].self,
				endpoint: "projects/\(projectId)/repository/branches"
			)
		} catch let error {
			Notify.status(.error, error.localizedDescription)
		}
	}

	var body: some View {
		List {
			if isLoading {
				LoadingView(
					"Loading branches and commits",
					systemImage: "chevron.left.forwardslash.chevron.right"
				)
			} else if let commits {
				switch commits {
				case .success(let commits):
					if commits.isEmpty {
						NoContentView(
							"You'll see your commits after you pushed something to branch \(refName)",
							systemImage: "chevron.left.forwardslash.chevron.right"
						)
					} else {
						HStack {
							Text("On branch")
							if branches != nil {
								Picker("", selection: $refName) {
									ForEach(branches!, id: \.name) { branch in
										Text(branch.name).tag(branch.name)
									}
								}.pickerStyle(.menu)
									.onChange(of: refName) {
										Task {
											await loadCommits()
										}
									}
							} else {
								Picker("", selection: $refName) {
									Text(refName).tag(refName)
								}.pickerStyle(.menu)
							}
						}
						Section("Commits") {
							ForEach(commits, id: \.id) { commit in
								NavigationLink(
									destination: DiffLoader(
										projectId: self.projectId, commitSha: commit.id),
									label: {
										HStack {
											VStack(alignment: .leading) {
												InlineMarkdown(commit.title)
													.fontWeight(.medium)

												ScrollView(.horizontal) {
													HStack {
														PillView(commit.authorName, icon: "person")
														PillView(commit.authoredDate.toString(.short), icon: "clock")
													}
												}.font(.footnote)
											}
											Spacer()
											VStack {
												SignatureLoader(
													projectId: self.projectId, commitId: commit.id)
												PillView(commit.shortId)
													.textSelection(.enabled)
													.font(.system(.footnote, design: .monospaced))
											}
										}.swipeActions {
											ShareButton(URL(string: commit.webUrl)!)
										}
									}
								)
							}
						}
					}
				case .failure(let error):
					FailedView(error)
				}
			}
		}.task {
			isLoading = true

			defer {
				isLoading = false
			}

			await loadCommits()
			await loadBranches()
		}.refreshable {
			isLoading = true

			defer {
				isLoading = false
			}

			await loadCommits()
			await loadBranches()
		}
		.navigationTitle("Commits")
		.headerProminence(.increased)
	}
}

#Preview {
	NavigationStack {
		CommitsLoader(33_025_310, refName: "main")
	}
}
