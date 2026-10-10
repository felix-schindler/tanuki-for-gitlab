//
//  NewProject.swift
//  GitLab
//
//  Created by Felix Schindler on 04.05.23.
//

import SwiftUI

struct Project: Codable {
	let id: Int
	let name: String
	let visibility: String
}

enum ProjectVisibility: String {
	case `public` = "public"
	case `internal` = "internal"
	case `private` = "private"
}

struct NewProjectView: View {
	@Environment(\.dismiss) private var dismiss

	private let namespaceId: Int?

	@State private var projectName = ""
	@State private var visibility = ProjectVisibility.private
	@State private var readme = false
	@State private var defaultBranch = "main"

	init(_ namespaceId: Int? = nil) {
		self.namespaceId = namespaceId
	}

	private func createProject() async {
		var body: [String: EncodableValue] = [
			"name": .string(projectName),
			"visibility": .string(visibility.rawValue),
		]

		if readme {
			body["initialize_with_readme"] = .boolean(true)
			body["default_branch"] = .string(defaultBranch)
		}

		if let namespaceId {
			body["namespace_id"] = .int(namespaceId)
		}

		do {
			let project = try await API.req(
				type: Project.self,
				method: .post,
				endpoint: "projects",
				body: body
			)

			Notify.status(.success, "Project \(project.name) created.")
			self.dismiss()
		} catch let error {
			Notify.status(.error, error.localizedDescription)
		}
	}

	var body: some View {
		Form {
			VStack(alignment: .leading) {
				TextField("Project name", text: $projectName)
				Text(
					"Must start with a lowercase or uppercase letter, digit, emoji, or underscore. Can also contain dots, pluses, dashes, or spaces."
				)
				.foregroundStyle(.secondary)
				.font(.footnote)
			}

			Picker("Visibility Level", selection: $visibility) {
				Label("Private", lucide: .lock)
					.tag(ProjectVisibility.private)
				Label("Public", lucide: .globe)
					.tag(ProjectVisibility.public)
				Label("Internal", lucide: .shieldHalf)
					.tag(ProjectVisibility.internal)
			}

			Toggle("Initialize with README", isOn: $readme)
			if readme {
				VStack(alignment: .leading) {
					TextField("Default branch", text: $defaultBranch)
						.autocorrectionDisabled()
						.textInputAutocapitalization(.never)
					Text("Default branch")
						.foregroundStyle(.secondary)
						.font(.footnote)
				}
			}
		}.toolbar {
			AsyncButton("Create Project", lucide: .check) {
				await createProject()
			}.tint(.accentColor)
		}
		.navigationTitle("New Project")
		.scrollDismissesKeyboard(.interactively)
	}
}

#Preview {
	NavigationStack {
		NewProjectView()
	}
}
