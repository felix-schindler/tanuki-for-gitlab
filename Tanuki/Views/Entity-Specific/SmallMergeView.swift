//
//  SmallMergeView.swift
//  Tanuki
//
//  Created by Felix Schindler on 28.02.24.
//

import GitLabAPI
import SwiftUI

struct SmallMergeView: View {
	private let fullPath: String
	private let mr: SmallMergeRequest

	init(_ fullPath: String, _ mr: SmallMergeRequest) {
		self.fullPath = fullPath
		self.mr = mr
	}

	public var body: some View {
		NavigationLink(
			destination: MergeRequestLoader(
				fullPath: fullPath,
				iid: mr.iid
			),
			label: {
				VStack(alignment: .leading) {
					HStack(spacing: 5) {
						MergeStateIcon(mr.state)
						Text(mr.reference)
							.foregroundStyle(.secondary)
					}.font(.footnote)
					Text(mr.title.emojized())
					ScrollView(.horizontal) {
						HStack {
							if let author = mr._author {
								AuthorView(author)
							}
							PillView(Date.fromToString(mr.createdAt), icon: .clock)
							PillView(String(mr.upvotes), icon: .thumbsUp)
							PillView(String(mr.downvotes), icon: .thumbsDown)
							PillView(String(mr.userNotesCount ?? 0), icon: .notebookText)
						}
					}.font(.footnote)
				}.swipeActions {
					if let webUrl = mr.webUrl,
						let url = URL(string: webUrl)
					{
						ShareButton(url)
					}
				}
			}
		)
	}
}
