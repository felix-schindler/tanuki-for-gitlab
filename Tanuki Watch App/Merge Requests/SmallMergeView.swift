//
//  SmallMergeView.swift
//  Tanuki Watch App
//
//  Created by Felix Schindler on 28.02.24.
//

import GitLabAPI
import SwiftUI
import TanukiShared

struct SmallMergeView: View {
	private let fullPath: String
	private let mr: SmallMergeRequest

	init(_ fullPath: String, _ mr: SmallMergeRequest) {
		self.fullPath = fullPath
		self.mr = mr
	}

	public var body: some View {
		VStack(alignment: .leading, spacing: 4) {
			HStack(spacing: 5) {
				MergeStateIcon(mr.state)
				Text(mr.reference)
					.foregroundStyle(.secondary)
			}.font(.footnote)
			Text(mr.title.emojized())
			if let author = mr._author {
				AuthorView(author)
			}
			HStack {
				HStack(spacing: 2) {
					Image(systemName: "clock")
					Text(
						Date.fromToString(mr.createdAt)
					)
				}
				Spacer()
				HStack(spacing: 2) {
					Image(systemName: "hand.thumbsup")
					Text(String(mr.upvotes))
				}
				HStack(spacing: 2) {
					Image(systemName: "hand.thumbsdown")
					Text(String(mr.downvotes))
				}
				HStack(spacing: 2) {
					Image(systemName: "note.text")
					Text(String(mr.userNotesCount ?? 0))
				}
			}.font(.footnote)
		}
	}
}

#Preview {
	SmallMergeView("gitlab-org/gitlab", MockMergeRequest())
}

private struct MockMergeRequest: SmallMergeRequest {
	let iid: String = "1"
	let title: String = "Add watch support"
	let reference: String = "!1"
	let state: GraphQLEnum<GitLabAPI.MergeRequestState> = .case(.opened)
	let upvotes: Int = 3
	let downvotes: Int = 0
	let userNotesCount: Int? = 2
	let _author: MyAuthor? = MyAuthor(avatarUrl: nil, name: "Felix", username: "felix")
	let createdAt: String = "2024-03-01T12:00:00Z"
	let webUrl: String? = nil
	let _project: MergeRequestProject = MockProject()
}

private struct MockProject: MergeRequestProject {
	let fullPath: String = "gitlab-org/gitlab"
}
