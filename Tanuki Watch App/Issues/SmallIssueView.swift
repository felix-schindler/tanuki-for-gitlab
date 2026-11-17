//
//  SmallIssueView.swift
//  Tanuki
//
//  Created by Felix Schindler on 07.03.24.
//

import SwiftUI
import TanukiShared

struct SmallIssueView: View {
	private let fullPath: String
	private let issue: SmallIssue

	init(_ fullPath: String, _ issue: SmallIssue) {
		self.fullPath = fullPath
		self.issue = issue
	}

	public var body: some View {
		VStack(alignment: .leading, spacing: 4) {
			HStack(spacing: 5) {
				IssueStateIcon(issue.state)
				Text(issue.reference)
					.foregroundStyle(.secondary)
			}.font(.footnote)
			Text(issue.title.emojized())
			AuthorView(issue._author)
			HStack {
				HStack(spacing: 2) {
					Image(systemName: "clock")
					Text(Date.fromToString(issue.createdAt))
				}
				Spacer()
				HStack(spacing: 2) {
					Image(systemName: "hand.thumbsup")
					Text(String(issue.upvotes))
				}
				HStack(spacing: 2) {
					Image(systemName: "hand.thumbsdown")
					Text(String(issue.downvotes))
				}
				HStack(spacing: 2) {
					Image(systemName: "note.text")
					Text(String(issue.userNotesCount))
				}
			}.font(.footnote)
		}
	}
}
