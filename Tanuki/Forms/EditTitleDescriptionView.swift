//
//  EditTitleDescriptionView.swift
//  Tanuki
//

import HighlightedTextEditor
import SwiftUI

struct EditTitleDescriptionView: View {
	@Environment(\.dismiss) private var dismiss

	private let projectId: Int
	private let iid: String
	private let type: AwardableType
	private let onSaved: () async -> Void

	@State private var title: String
	@State private var description: String

	init(
		projectId: Int,
		iid: String,
		type: AwardableType,
		initialTitle: String,
		initialDescription: String,
		onSaved: @escaping () async -> Void = {}
	) {
		self.projectId = projectId
		self.iid = iid
		self.type = type
		self.onSaved = onSaved
		_title = State(initialValue: initialTitle)
		_description = State(initialValue: initialDescription)
	}

	private func save() async {
		guard title.isNotEmpty else {
			Notify.status(.error, "Please enter a title.")
			return
		}
		let body: [String: EncodableValue] = [
			"title": .string(title),
			"description": .string(description),
		]
		do {
			_ = try await API.raw(
				method: .put,
				endpoint: "projects/\(projectId)/\(type.path)/\(iid)",
				body: body
			)
			Notify.status(.success, "Changes saved")
			await onSaved()
			dismiss()
		} catch {
			Notify.status(.error, "Failed to save changes", error.localizedDescription)
		}
	}

	var body: some View {
		Form {
			TextField("Title (required)", text: $title)
			Section("Description (Markdown supported)") {
				HighlightedTextEditor(text: $description, highlightRules: .markdown)
					.frame(minHeight: 100)
			}
		}
		.toolbar {
			AsyncButton("Save", systemImage: "checkmark") {
				await save()
			}.tint(.accentColor)
		}
		.navigationTitle(type == .issue ? "Edit Issue" : "Edit Merge Request")
		.scrollDismissesKeyboard(.interactively)
	}
}
