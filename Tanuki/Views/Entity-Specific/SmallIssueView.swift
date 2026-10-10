//
//  SmallIssueView.swift
//  Tanuki
//
//  Created by Felix Schindler on 07.03.24.
//

import SwiftUI

struct SmallIssueView: View {
	private let fullPath: String
	private let issue: SmallIssue

	init(_ fullPath: String, _ issue: SmallIssue) {
		self.fullPath = fullPath
		self.issue = issue
	}

	public var body: some View {
		NavigationLink(
			destination: IssueLoader(
				fullPath: self.fullPath, iid: issue.iid
			),
			label: {
				VStack(alignment: .leading) {
					HStack(spacing: 5) {
						IssueStateIcon(issue.state)
						Text(issue.reference)
							.foregroundStyle(.secondary)
					}.font(.footnote)
					Text(issue.title.emojized())
					ScrollView(.horizontal) {
						HStack {
							AuthorView(issue._author)
							PillView(Date.fromToString(issue.createdAt), icon: .clock)
							PillView(String(issue.upvotes), icon: .thumbsUp)
							PillView(String(issue.downvotes), icon: .thumbsDown)
							PillView(String(issue.userNotesCount), icon: .notebookText)
						}
					}.font(.footnote)
				}.swipeActions {
					if let url = URL(string: issue.webUrl) {
						ShareButton(url)
					}
				}
			}
		)
	}
}
