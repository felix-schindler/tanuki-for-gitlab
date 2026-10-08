//
//  EditProjectView.swift
//  Tanuki
//

import SwiftUI

struct EditProjectView: View {
	@Environment(\.dismiss) private var dismiss

	private let projectId: Int

	@State private var name: String
	@State private var description: String
	@State private var visibility: ProjectVisibility

	init(projectId: Int, name: String, description: String?, visibility: String) {
		self.projectId = projectId
		_name = State(initialValue: name)
		_description = State(initialValue: description ?? "")
		_visibility = State(initialValue: ProjectVisibility(rawValue: visibility) ?? .private)
	}

	private func saveProject() async {
		guard name.isNotEmpty else {
			Notify.status(.error, "Please enter a project name.")
			return
		}

		let body: [String: EncodableValue] = [
			"name": .string(name),
			"description": .string(description),
			"visibility": .string(visibility.rawValue),
		]

		do {
			let project = try await API.req(
				type: Project.self,
				method: .put,
				endpoint: "projects/\(projectId)",
				body: body
			)

			Notify.status(.success, "Project \(project.name) saved.")
			self.dismiss()
		} catch let error {
			Notify.status(.error, "Failed to save project", error.localizedDescription)
		}
	}

	var body: some View {
		Form {
			TextField("Project name", text: $name)
			TextField("Description (optional)", text: $description, axis: .vertical)

			Picker("Visibility Level", selection: $visibility) {
				Label("Private", systemImage: "lock")
					.tag(ProjectVisibility.private)
				Label("Public", systemImage: "globe")
					.tag(ProjectVisibility.public)
				Label("Internal", systemImage: "shield.lefthalf.filled")
					.tag(ProjectVisibility.internal)
			}
		}.toolbar {
			AsyncButton("Save", systemImage: "checkmark") {
				await saveProject()
			}.tint(.accentColor)
		}
		.navigationTitle("Project Settings")
		.scrollDismissesKeyboard(.interactively)
	}
}

#Preview {
	NavigationStack {
		EditProjectView(projectId: 33_025_310, name: "tanuki", description: nil, visibility: "private")
	}
}
