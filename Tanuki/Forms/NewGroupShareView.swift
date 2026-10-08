//
//  NewGroupShareView.swift
//  Tanuki
//

import SwiftUI

struct NewGroupShareView: View {
	@Environment(\.dismiss) private var dismiss

	/// Project ID
	private let id: Int

	init(id: Int) {
		self.id = id
	}

	@State private var groupPath = ""
	@State private var accessLevel: ProjectRole = .guest
	@State private var setExpDate = false
	@State private var expDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())!

	private func shareWithGroup() async {
		do {
			let query = groupPath.trimmingCharacters(in: .whitespacesAndNewlines)
			let groups = try await API.get(
				type: [RestAPIGroup].self, endpoint: "groups", query: ["search": query])

			guard let group = groups.first(where: { $0.fullPath == query }) ?? groups.first else {
				Notify.status(
					.error, "No such group", "No group named \"\(query)\" was found on this instance.",
					systemImage: "person.2.badge.plus")
				return
			}

			var shareDict = [
				"group_id": String(group.id),
				"group_access": String(accessLevel.rawValue),
			]

			if setExpDate {
				let inputFormatter = DateFormatter()
				inputFormatter.dateFormat = "yyyy-MM-dd"
				shareDict["expires_at"] = inputFormatter.string(from: expDate)
			}

			_ = try await API.req(
				type: RestAPIProject.self, method: .post, endpoint: "projects/\(id)/share",
				body: shareDict)
			self.dismiss()
		} catch let error {
			Notify.status(.error, error.localizedDescription)
		}
	}

	public var body: some View {
		Form {
			TextField("Group path", text: $groupPath)
				.textInputAutocapitalization(.never)
				.autocorrectionDisabled()

			Picker("Role", selection: $accessLevel) {
				Text("Minimal").tag(ProjectRole.minimal)
				Text("Guest").tag(ProjectRole.guest)
				Text("Planner").tag(ProjectRole.planner)
				Text("Reporter").tag(ProjectRole.reporter)
				Text("Developer").tag(ProjectRole.developer)
				Text("Maintainer").tag(ProjectRole.maintainer)
				Text("Owner").tag(ProjectRole.owner)
			}

			VStack(alignment: .leading) {
				Toggle("Set expiration", isOn: $setExpDate)
				if setExpDate {
					DatePicker("Expiration", selection: $expDate, displayedComponents: .date)
				}
			}
		}.toolbar {
			AsyncButton("Share", systemImage: "checkmark") {
				await shareWithGroup()
			}.tint(.accentColor)
		}.navigationTitle("Share with Group")
	}
}

#Preview {
	NavigationStack {
		NewGroupShareView(id: 1)
	}
}
