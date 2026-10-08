//
//  NewBranchView.swift
//  Tanuki
//

import SwiftUI

struct CreatedBranch: Codable {
	let name: String
}

struct NewBranchView: View {
	@Environment(\.dismiss) private var dismiss

	private let projectId: Int

	@State private var name = ""
	@State private var ref = "main"

	init(projectId: Int) {
		self.projectId = projectId
	}

	private func createBranch() async {
		guard name.isNotEmpty else {
			Notify.status(.error, "Please enter a branch name.")
			return
		}

		let body: [String: EncodableValue] = [
			"branch": .string(name),
			"ref": .string(ref.isEmpty ? "main" : ref),
		]

		do {
			let branch = try await API.req(
				type: CreatedBranch.self,
				method: .post,
				endpoint: "projects/\(projectId)/repository/branches",
				body: body
			)

			Notify.status(.success, "Branch \(branch.name) created.")
			self.dismiss()
		} catch let error {
			Notify.status(.error, "Failed to create branch", error.localizedDescription)
		}
	}

	var body: some View {
		Form {
			TextField("New branch name", text: $name)
				.textInputAutocapitalization(.never)
				.autocorrectionDisabled()
			TextField("Create from (branch, tag or commit)", text: $ref)
				.textInputAutocapitalization(.never)
				.autocorrectionDisabled()
		}.toolbar {
			AsyncButton("Create branch", systemImage: "checkmark") {
				await createBranch()
			}.tint(.accentColor)
		}
		.navigationTitle("New Branch")
		.scrollDismissesKeyboard(.interactively)
	}
}

#Preview {
	NavigationStack {
		NewBranchView(projectId: 33_025_310)
	}
}
