//
//  NewGroupView.swift
//  Tanuki
//
//  Created by Felix Schindler on 08.10.26.
//

import SwiftUI

struct NewGroupView: View {
	@Environment(\.dismiss) private var dismiss

	private let parentId: Int?

	init(parentId: Int? = nil) {
		self.parentId = parentId
	}

	@State private var name = ""
	@State private var path = ""
	@State private var description = ""
	@State private var visibility = ProjectVisibility.private

	private func createGroup() async {
		guard name.isNotEmpty else {
			Notify.status(.error, "Please enter a name.")
			return
		}
		var body: [String: EncodableValue] = [
			"name": .string(name),
			"path": .string(path.isEmpty ? name.lowercased().replacing(" ", with: "-") : path),
			"visibility": .string(visibility.rawValue),
		]
		if let parentId {
			body["parent_id"] = .int(parentId)
		}
		if description.isNotEmpty {
			body["description"] = .string(description)
		}
		do {
			let group = try await API.req(
				type: RestAPIGroup.self,
				method: .post,
				endpoint: "groups",
				body: body
			)
			Notify.status(.success, "Group \(group.name ?? "group") created.")
			dismiss()
		} catch {
			Notify.status(.error, error.localizedDescription)
		}
	}

	var body: some View {
		Form {
			TextField("Group name (required)", text: $name)
			TextField("Group path", text: $path)
				.autocorrectionDisabled()
				.textInputAutocapitalization(.never)
			Picker("Visibility Level", selection: $visibility) {
				Label("Private", systemImage: "lock").tag(ProjectVisibility.private)
				Label("Public", systemImage: "globe").tag(ProjectVisibility.public)
				Label("Internal", systemImage: "shield.lefthalf.filled").tag(ProjectVisibility.internal)
			}
			TextField("Description (optional)", text: $description, axis: .vertical)
		}.toolbar {
			AsyncButton(parentId == nil ? "Create Group" : "Create Subgroup", systemImage: "checkmark") {
				await createGroup()
			}.tint(.accentColor)
		}
		.navigationTitle(parentId == nil ? "New Group" : "New Subgroup")
		.scrollDismissesKeyboard(.interactively)
	}
}

#Preview {
	NavigationStack {
		NewGroupView()
	}
}
