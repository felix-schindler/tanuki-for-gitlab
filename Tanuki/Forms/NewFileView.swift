//
//  NewFileView.swift
//  Tanuki
//

import SwiftUI

struct CreatedFile: Codable {
	let filePath: String
}

struct NewFileView: View {
	@Environment(\.dismiss) private var dismiss

	private let projectId: Int

	@State private var path: String
	@State private var branch: String
	@State private var commitMessage = ""
	@State private var content = ""

	init(projectId: Int, refName: String, folderPath: String? = nil) {
		self.projectId = projectId
		_path = State(initialValue: folderPath.map { "\($0)/" } ?? "")
		_branch = State(initialValue: refName)
	}

	private func createFile() async {
		guard path.isNotEmpty else {
			Notify.status(.error, "Please enter a file path.")
			return
		}
		guard commitMessage.isNotEmpty else {
			Notify.status(.error, "Please enter a commit message.")
			return
		}

		let body: [String: EncodableValue] = [
			"branch": .string(branch.isEmpty ? "main" : branch),
			"content": .string(content),
			"commit_message": .string(commitMessage),
		]

		do {
			let file = try await API.req(
				type: CreatedFile.self,
				method: .post,
				endpoint: "projects/\(projectId)/repository/files",
				resource: path,
				body: body
			)

			Notify.status(.success, "File \(file.filePath) created.")
			self.dismiss()
		} catch let error {
			Notify.status(.error, "Failed to create file", error.localizedDescription)
		}
	}

	var body: some View {
		Form {
			TextField("File path (e.g. docs/notes.md)", text: $path)
				.textInputAutocapitalization(.never)
				.autocorrectionDisabled()
			TextField("Branch", text: $branch)
				.textInputAutocapitalization(.never)
				.autocorrectionDisabled()
			TextField("Commit message", text: $commitMessage, axis: .vertical)

			Section("Content") {
				TextEditor(text: $content)
					.frame(minHeight: 200)
					.font(.system(.body, design: .monospaced))
					.textInputAutocapitalization(.never)
					.autocorrectionDisabled()
			}
		}.toolbar {
			AsyncButton("Create file", systemImage: "checkmark") {
				await createFile()
			}.tint(.accentColor)
		}
		.navigationTitle("New File")
		.scrollDismissesKeyboard(.interactively)
	}
}

#Preview {
	NavigationStack {
		NewFileView(projectId: 33_025_310, refName: "main")
	}
}
