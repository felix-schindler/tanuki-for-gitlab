//
//  CommitsLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 29.03.24.
//

import GitLabAPI
import SwiftUI

struct MrCommitsLoader: View {
	private let fullPath: String
	private let iid: String

	@State
	private var project: Result<MergeRequestCommitsQuery.Data.Project, Error>? = nil

	init(fullPath: String, iid: String) {
		self.fullPath = fullPath
		self.iid = iid
	}

	private func loadCommits() {
		do {
			let responses = try Network.shared.apollo.fetch(
				query: MergeRequestCommitsQuery(fullPath: self.fullPath, iid: self.iid),
				cachePolicy: .cacheAndNetwork
			)

			Task {
				for try await response in responses {
					if let project = response.data?.project {
						self.project = .success(project)
					} else if let errors = response.errors {
						for error in errors {
							Notify.status(.error, error.localizedDescription)
						}
					}
				}
			}
		} catch let error {
			self.project = .failure(error)
			Notify.status(.error)
		}
	}

	private func reloadCommits() async {
		do {
			let response = try await Network.shared.apollo.fetch(
				query: MergeRequestCommitsQuery(fullPath: self.fullPath, iid: self.iid),
				cachePolicy: .networkOnly
			)

			if let project = response.data?.project {
				self.project = .success(project)
			}

			Notify.status(.success)
		} catch let error {
			self.project = .failure(error)
			Notify.status(.error)
		}
	}

	public var body: some View {
		List {
			if let project {
				switch project {
				case .success(let project):
					if let projectId = project.id.toIntId(),
						let commits = project.mergeRequest?.commits?.nodes,
						commits.isNotEmpty
					{
						ForEach(commits, id: \.?.shortId) { maybeCommit in
							if let commit = maybeCommit {
								SmallCommitView(commit, projectId)
							}
						}
					} else {
						NoContentView(
							"There are no commits in this MR",
							lucide: .gitCommitHorizontal)
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading Commits", lucide: .gitCommitHorizontal)
			}
		}.task {
			loadCommits()
		}.refreshable {
			await reloadCommits()
		}.navigationTitle("Commits")
	}
}

#Preview {
	NavigationStack {
		MrCommitsLoader(fullPath: "felix-schindler/gitlab-ios", iid: "1")
	}
}
