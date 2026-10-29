//
//  NewSnippetView.swift
//  Tanuki
//
//  Created by Felix Schindler on 08.10.26.
//

import SwiftUI

struct NewSnippetView: View {
	@Environment(\.dismiss) private var dismiss

	@State private var title = ""
	@State private var fileName = ""
	@State private var content = ""
	@State private var description = ""
	@State private var visibility = ProjectVisibility.private

	private func createSnippet() async {
		guard title.isNotEmpty else {
			Notify.status(.error, "Please enter a title.")
			return
		}
		guard content.isNotEmpty else {
			Notify.status(.error, "Please enter some content.")
			return
		}
		var body: [String: EncodableValue] = [
			"title": .string(title),
			"content": .string(content),
			"visibility": .string(visibility.rawValue),
		]
		if fileName.isNotEmpty {
			body["file_name"] = .string(fileName)
		}
		if description.isNotEmpty {
			body["description"] = .string(description)
		}
		do {
			let snippet = try await API.req(
				type: RestAPISnippet.self,
				method: .post,
				endpoint: "snippets",
				body: body
			)
			Notify.status(.success, "Snippet \(snippet.title) created.")
			dismiss()
		} catch {
			Notify.status(.error, error.localizedDescription)
		}
	}

	var body: some View {
		Form {
			TextField("Title (required)", text: $title)
			TextField("File name (optional, e.g. notes.md)", text: $fileName)
				.autocorrectionDisabled()
				.textInputAutocapitalization(.never)
			Picker("Visibility Level", selection: $visibility) {
				Label("Private", lucide: .lock).tag(ProjectVisibility.private)
				Label("Public", lucide: .globe).tag(ProjectVisibility.public)
				Label("Internal", lucide: .shieldHalf).tag(ProjectVisibility.internal)
			}
			Section("Content (required)") {
				TextEditor(text: $content)
					.frame(minHeight: 150)
					.autocorrectionDisabled()
					.textInputAutocapitalization(.never)
			}
			TextField("Description (optional)", text: $description, axis: .vertical)
		}.toolbar {
			AsyncButton("Create Snippet", lucide: .check) {
				await createSnippet()
			}.tint(.accentColor)
		}
		.navigationTitle("New Snippet")
		.scrollDismissesKeyboard(.interactively)
	}
}

#Preview {
	NavigationStack {
		NewSnippetView()
	}
}
