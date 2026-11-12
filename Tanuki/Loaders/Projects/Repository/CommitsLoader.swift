//
//  Commits.swift
//  GitLab
//
//  Created by Felix Schindler on 02.11.21.
//

import Foundation
import GitLabAPI
import SwiftUI

struct Commit: Codable {
	let id: String
	let shortId: String
	let title: String
	let message: String
	let authorName: String
	let authoredDate: Foundation.Date
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

/// Bridges the REST commit model to `SmallCommitView`, which is typed against the
/// GraphQL commit selection.
private struct RestCommit: NewCommit {
	let commit: Commit
	let verificationStatus: String?

	var id: String { commit.id }
	var shortId: String { commit.shortId }
	var title: String? { commit.title }
	var authorName: String? { commit.authorName }
	var _author: MyAuthor? { nil }
	var authoredDate: GitLabAPI.Time? { commit.authoredDate.ISO8601Format() }
	var webUrl: String { commit.webUrl }
	var _signatureVerificationStatus: String? { verificationStatus }
	var _lastPipelineStatus: GraphQLEnum<GitLabAPI.PipelineStatusEnum>? { nil }
}

/// A REST commit rendered by `SmallCommitView`, adding the signature status that
/// GraphQL would otherwise provide.
private struct CommitRow: View {
	let commit: Commit
	let projectId: Int

	@State
	private var verificationStatus: String?

	var body: some View {
		SmallCommitView(RestCommit(commit: commit, verificationStatus: verificationStatus), projectId)
			.task {
				let signature = await CommitSignature.load(projectId: projectId, commitId: commit.id)
				verificationStatus = signature?.verificationStatus.uppercased()
			}
	}
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

	@State
	private var loadTask: Task<Void, Never>?

	private func loadCommits() async {
		do {
			let temp = try await API.get(
				type: [Commit].self,
				endpoint: "projects/\(projectId)/repository/commits",
				query: ["ref_name": refName]
			)

			if Task.isCancelled { return }
			self.commits = .success(temp)
		} catch let error {
			if Task.isCancelled { return }
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
					systemImage: Icons.code.rawValue
				)
			} else if let commits {
				switch commits {
				case .success(let commits):
					if commits.isEmpty {
						NoContentView(
							"You'll see your commits after you pushed something to branch \(refName)",
							systemImage: Icons.code.rawValue
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
										loadTask?.cancel()
										loadTask = Task {
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
								CommitRow(commit: commit, projectId: self.projectId)
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
