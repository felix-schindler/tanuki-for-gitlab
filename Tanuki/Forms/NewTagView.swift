//
//  NewTagView.swift
//  Tanuki
//

import SwiftUI

struct CreatedTag: Codable {
	let name: String
}

struct NewTagView: View {
	@Environment(\.dismiss) private var dismiss

	private let projectId: Int

	@State private var name = ""
	@State private var ref = "main"
	@State private var message = ""

	init(projectId: Int) {
		self.projectId = projectId
	}

	private func createTag() async {
		guard name.isNotEmpty else {
			Notify.status(.error, "Please enter a tag name.")
			return
		}

		var body: [String: EncodableValue] = [
			"tag_name": .string(name),
			"ref": .string(ref.isEmpty ? "main" : ref),
		]

		if message.isNotEmpty {
			body["message"] = .string(message)
		}

		do {
			let tag = try await API.req(
				type: CreatedTag.self,
				method: .post,
				endpoint: "projects/\(projectId)/repository/tags",
				body: body
			)

			Notify.status(.success, "Tag \(tag.name) created.")
			self.dismiss()
		} catch let error {
			Notify.status(.error, "Failed to create tag", error.localizedDescription)
		}
	}

	var body: some View {
		Form {
			TextField("New tag name", text: $name)
				.textInputAutocapitalization(.never)
				.autocorrectionDisabled()
			TextField("Create from (branch, tag or commit)", text: $ref)
				.textInputAutocapitalization(.never)
				.autocorrectionDisabled()
			TextField("Message (optional)", text: $message, axis: .vertical)
		}.toolbar {
			AsyncButton("Create tag", systemImage: "checkmark") {
				await createTag()
			}.tint(.accentColor)
		}
		.navigationTitle("New Tag")
		.scrollDismissesKeyboard(.interactively)
	}
}

#Preview {
	NavigationStack {
		NewTagView(projectId: 33_025_310)
	}
}
