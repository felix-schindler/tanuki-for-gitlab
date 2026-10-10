//
//  NewMemberView.swift
//  Tanuki
//
//  Created by Felix Schindler on 20.09.25.
//

import SwiftUI

enum ProjectRole: Int {
	case minimal = 5
	case guest = 10
	case planner = 15
	case reporter = 20
	case developer = 30
	case maintainer = 40
	case owner = 50
}

struct NewMemberView: View {
	@Environment(\.dismiss) private var dismiss

	/// Project ID
	private let id: Int
	/// Group ID
	private let groupId: Int

	init(id: Int, groupId: Int) {
		self.id = id
		self.groupId = groupId
	}

	@State private var username = ""
	@State private var accessLevel: ProjectRole = .guest
	@State private var setExpDate = false
	@State private var expDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())!

	private func addMember() async {
		do {
			let users = try await API.get(
				type: [UserSmall?].self, endpoint: "users", query: ["username": username])

			guard let currentUser = users.compactMap({ $0 }).first else {
				Notify.status(
					.error, "No such user", "No user named \"\(username)\" was found on this instance.",
					systemImage: "person.badge.plus")
				return
			}

			var memberDict = [
				"user_id": String(currentUser.id),
				"access_level": String(accessLevel.rawValue),
			]

			if setExpDate {
				let inputFormatter = DateFormatter()
				inputFormatter.dateFormat = "yyyy-MM-dd"
				memberDict["expires_at"] = inputFormatter.string(from: expDate)
			}

			let endpoint: String =
				(id != 0 ? "projects/\(id)/members" : "groups/\(groupId)/members")
			_ = try await API.req(
				type: UserSmall.self, method: .post, endpoint: endpoint, body: memberDict)
			self.dismiss()
		} catch let error {
			Notify.status(.error, error.localizedDescription)
		}
	}

	public var body: some View {
		Form {
			TextField("Username", text: $username)
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
			AsyncButton("Add member", lucide: .check) {
				await addMember()
			}.tint(.accentColor)
		}.navigationTitle("New Member")
	}
}

#Preview {
	NavigationStack {
		NewMemberView(id: 1, groupId: 1)
	}
}
