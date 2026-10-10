//
//  NoteView.swift
//  Tanuki
//
//  Created by Felix Schindler on 27.02.24.
//

import GitLabAPI
import Lucide
import SwiftUI

struct NoteView: View {
	private let projectId: Int
	private let note: Note

	init(_ note: Note, projectId: Int = 0) {
		self.note = note
		self.projectId = projectId
	}

	private func convertIconName(_ iconName: String?) -> LucideIcon {
		switch iconName {
		case "user":
			.user
		case "comment-dots":
			.messageSquare
		case "pencil":
			.pencil
		case "commit":
			.gitCommitHorizontal
		case "check":
			.userCheck
		case "unapproval":
			.userX
		case "timer":
			.hourglass
		case "label":
			.tag
		case "link":
			.link
		case "unlink":
			.unlink
		case "arrow-right":
			.forward
		case "clock":
			.clock
		case "duplicate":
			.copy
		case "issue-close":
			.circleMinus
		case "issues":
			.circleDot
		case "status-health":
			.activity
		default:
			.circleQuestionMark
		}
	}

	public var body: some View {
		if let author = note._author {
			if note.system {
				Label(
					"@\(author.username) \(note.body)",
					lucide: convertIconName(note.systemNoteIconName)
				)
				.font(.footnote)
			} else {
				VStack(alignment: .leading) {
					ScrollView(.horizontal) {
						HStack {
							AuthorView(author, showUsername: true)

							if let accessLevel = note.maxAccessLevelOfAuthor {
								PillView(accessLevel)
							}

							if note.updatedAt != note.createdAt {
								PillView(
									Date.fromToString(note.createdAt, dateStyle: .short, timeStyle: .short),
									icon: .pencilLine)
							} else {
								PillView(
									Date.fromToString(note.createdAt, dateStyle: .short, timeStyle: .short),
									icon: .clock)
							}
						}
					}.font(.footnote)

					Markdown(
						note.body,
						baseURL: API.url,
						imageBaseURL: URL(
							string: "\(API.url.absoluteString)/-/project/\(self.projectId)")
					)
				}
			}
		} else {
			Label(
				title: {
					InlineMarkdown(note.body, baseURL: API.url)
				},
				icon: {
					LucideLabelIcon(convertIconName(note.systemNoteIconName))
				}
			).font(.footnote)
		}
	}
}
