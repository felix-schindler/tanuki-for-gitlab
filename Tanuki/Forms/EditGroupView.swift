//
//  EditGroupView.swift
//  Tanuki
//
//  Created by Felix Schindler on 08.10.26.
//

import SwiftUI

struct SavedGroup: Codable {
	let id: Int
	let name: String
}

struct EditGroupView: View {
	@Environment(\.dismiss) private var dismiss

	private let groupId: Int

	@State private var name: String
	@State private var description: String
	@State private var visibility: ProjectVisibility

	init(groupId: Int, name: String, description: String?, visibility: String) {
		self.groupId = groupId
		_name = State(initialValue: name)
		_description = State(initialValue: description ?? "")
		_visibility = State(initialValue: ProjectVisibility(rawValue: visibility) ?? .private)
	}

	private func saveGroup() async {
		guard name.isNotEmpty else {
			Notify.status(.error, "Please enter a group name.")
			return
		}

		let body: [String: EncodableValue] = [
			"name": .string(name),
			"description": .string(description),
			"visibility": .string(visibility.rawValue),
		]

		do {
			let group = try await API.req(
				type: SavedGroup.self,
				method: .put,
				endpoint: "groups/\(groupId)",
				body: body
			)

			Notify.status(.success, "Group \(group.name) saved.")
			self.dismiss()
		} catch let error {
			Notify.status(.error, "Failed to save group", error.localizedDescription)
		}
	}

	var body: some View {
		Form {
			TextField("Group name", text: $name)
			TextField("Description (optional)", text: $description, axis: .vertical)

			Picker("Visibility Level", selection: $visibility) {
				Label("Private", lucide: .lock)
					.tag(ProjectVisibility.private)
				Label("Public", lucide: .globe)
					.tag(ProjectVisibility.public)
				Label("Internal", lucide: .shieldHalf)
					.tag(ProjectVisibility.internal)
			}
		}.toolbar {
			AsyncButton("Save", lucide: .check) {
				await saveGroup()
			}.tint(.accentColor)
		}
		.navigationTitle("Group Settings")
		.scrollDismissesKeyboard(.interactively)
	}
}

#Preview {
	NavigationStack {
		EditGroupView(groupId: 1, name: "tanuki", description: nil, visibility: "private")
	}
}
