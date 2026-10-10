//
//  SmallCommitView.swift
//  Tanuki
//
//  Created by Felix Schindler on 29.03.24.
//

import SwiftUI

struct SmallCommitView: View {
	private let projectId: Int?
	private let commit: NewCommit

	@State
	private var showVerified = false

	init(_ commit: NewCommit, _ projectId: Int? = nil) {
		self.commit = commit
		self.projectId = projectId
	}

	public var body: some View {
		if let id = self.projectId,
			let sha = commit.id.toStringId()
		{
			NavigationLink(
				destination: DiffLoader(projectId: id, commitSha: sha),
				label: {
					main
				}
			)
		} else {
			main
		}
	}

	private var main: some View {
		HStack {
			VStack(alignment: .leading) {
				if let title = commit.title, title.isNotEmpty {
					InlineMarkdown(title)
				}

				if commit.authorName != nil
					&& commit.authoredDate != nil
				{
					ScrollView(.horizontal) {
						HStack {
							PillView(commit.authorName!, icon: .user)
							PillView(Date.fromToString(commit.authoredDate!), icon: .clock)
						}
					}
					.font(.footnote)
				}
			}

			Spacer()

			VStack {
				HStack {
					if let status = commit._lastPipelineStatus {
						PipelineStatus(status)
					}

					if commit._signatureVerificationStatus?.starts(with: "VERIFIED") ?? false {
						RoundIconButton(
							"Verified", icon: .badgeCheck
						) {
							Haptics.shared.play(.light)
							showVerified = true
						}
						.tint(.green)
						.controlSize(.mini)
					}
				}

				PillView(commit.shortId)
					.textSelection(.enabled)
					.font(.system(.footnote, design: .monospaced))
			}
		}.sheet(isPresented: $showVerified) {
			VStack(alignment: .leading) {
				PopupHeader(
					title: "Verified commit",
					onClose: {
						showVerified = false
					})
				Text(
					"This commit was signed with a verified signature and the committer email was verified to belong to the same user."
				)
				Spacer()
			}
			.padding()
			.presentationDetents([.fraction(0.2), .medium])
		}.swipeActions {
			if let url = URL(string: commit.webUrl) {
				ShareButton(url)
			}
		}
	}
}
