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
					HStack {
						ScrollView(.horizontal) {
							HStack {
								AuthorView(issue._author)
								Label(
									Date.fromToString(issue.createdAt), lucide: .clock,
									size: 17)
							}
						}
						Spacer()
						HStack {
							Label(String(issue.upvotes), lucide: .thumbsUp, size: 17)
							Label(String(issue.downvotes), lucide: .thumbsDown, size: 17)
							Label(String(issue.userNotesCount), lucide: .notebookText, size: 17)
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
