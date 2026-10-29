//
//  NoteView.swift
//  Tanuki
//
//  Created by Felix Schindler on 27.02.24.
//

import GitLabAPI
import SwiftUI

struct NoteView: View {
	private let projectId: Int
	private let note: Note

	init(_ note: Note, projectId: Int = 0) {
		self.note = note
		self.projectId = projectId
	}

	private func convertIconName(_ iconName: String?) -> String {
		switch iconName {
		case "user":
			"person"
		case "comment-dots":
			"ellipsis.bubble"
		case "pencil":
			"pencil"
		case "commit":
			"circle.and.line.horizontal"
		case "check":
			"person.fill.checkmark"
		case "unapproval":
			"person.fill.xmark"
		case "timer":
			"hourglass"
		case "label":
			"tag"
		case "link":
			"link.badge.plus"
		case "unlink":
			"link"
		case "arrow-right":
			"arrowshape.turn.up.forward"
		case "clock":
			"clock"
		case "duplicate":
			"circlebadge.2"
		case "issue-close":
			"minus.circle"
		case "issues":
			"smallcircle.circle"
		case "status-health":
			"waveform.path.ecg"
		default:
			"questionmark"
		}
	}

	public var body: some View {
		if let author = note._author {
			if note.system {
				Label(
					"@\(author.username) \(note.body)",
					systemImage: convertIconName(note.systemNoteIconName)
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
									icon: "pencil.and.scribble")
							} else {
								PillView(
									Date.fromToString(note.createdAt, dateStyle: .short, timeStyle: .short),
									icon: "clock")
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
					Image(systemName: convertIconName(note.systemNoteIconName))
				}
			).font(.footnote)
		}
	}
}
