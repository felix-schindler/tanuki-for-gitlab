//
//  NewNoteView.swift
//  Tanuki
//
//  Created by Felix Schindler on 18.02.26.
//

import HighlightedTextEditor
import SwiftUI

private struct _Note: Codable {
	let id: Int
}

enum NoteType: String {
	case issue = "issues"
	case snippet = "snippets"
	case mergeRequest = "merge_requests"
}

struct NewNoteView: View {
	private let id: Int
	private let iid: String
	private let type: NoteType

	@State private var show = false
	@State private var content: String = ""
	@State private var `internal` = false

	init(_ id: Int, iid: String, type: NoteType) {
		self.id = id
		self.iid = iid
		self.type = type
	}

	private func createNote() async {
		do {
			let endpoint = "projects/\(id)/\(type.rawValue)/\(iid)/notes"

			_ = try await API.req(
				type: _Note.self,
				method: .post,
				endpoint: endpoint,
				query: ["body": content, "internal": self.type != .snippet && self.internal ? "true" : "false"]
			)

			Notify.status(.success, "Note created", systemImage: "checkmark")
			content = ""
			show = false
		} catch {
			Notify.status(.error, "Couldn't create note", error.localizedDescription, systemImage: "xmark")
		}
	}

	public var body: some View {
		Button("New note", lucide: .arrowUp) {
			show = true
		}.sheet(isPresented: $show) {
			NavigationStack {
				Form {
					Section("Description (Markdown supported)") {
						HighlightedTextEditor(text: $content, highlightRules: .markdown)
							.frame(minHeight: 100)
					}

					if type != .snippet {
						Toggle("Internal", isOn: self.$internal)
					}
				}.toolbar {
					AsyncButton("Create note", lucide: .check) {
						await createNote()
					}.tint(.accentColor)
				}
				.navigationTitle("New note")
				.navigationBarTitleDisplayMode(.inline)
				.scrollDismissesKeyboard(.interactively)
			}
		}
	}
}

#Preview {
	List {
		NewNoteView(33_025_310, iid: "42", type: .issue)
	}
}
