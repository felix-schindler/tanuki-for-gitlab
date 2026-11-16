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
	private var loader = ApolloLoader<MergeRequestCommitsQuery, MergeRequestCommitsQuery.Data.Project> {
		$0.project
	}

	init(fullPath: String, iid: String) {
		self.fullPath = fullPath
		self.iid = iid
	}

	public var body: some View {
		let state = loader.state

		List {
			if state.isInitialLoading {
				LoadingView("Loading Commits", systemImage: Icons.commits.rawValue)
			} else if state.isColdFailure, let error = state.error {
				FailedView(error)
			} else if let project = state.value {
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
						systemImage: Icons.commits.rawValue)
				}
			}

		}.task {
			await loader.load(MergeRequestCommitsQuery(first: 100, after: .none, fullPath: fullPath, iid: iid))
		}.refreshable {
			await loader.reload(MergeRequestCommitsQuery(first: 100, after: .none, fullPath: fullPath, iid: iid))
		}.navigationTitle("Commits")
	}
}

#Preview {
	NavigationStack {
		MrCommitsLoader(fullPath: "felix-schindler/gitlab-ios", iid: "1")
	}
}
