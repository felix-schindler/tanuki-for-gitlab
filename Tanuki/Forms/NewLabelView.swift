//
//  NewLabelView.swift
//  Tanuki
//
//  Created by Felix Schindler on 20.09.25.
//

import HighlightedTextEditor
import SwiftUI

struct NewLabelView: View {
	@Environment(\.dismiss) private var dismiss

	/// Project ID
	private let id: Int
	/// Group ID
	private let groupId: Int

	init(id: Int, groupId: Int) {
		self.id = id
		self.groupId = groupId
	}

	@State private var title: String = ""
	@State private var description: String = ""
	@State private var color: Color = Color(.red)
	@State private var prio: Int = -1

	private func saveNewLabel() async {
		var query: [String: String] = [
			"name": title,
			"color": "#\(color.hex!.dropLast(2))",
		]

		if description != "" {
			query["description"] = description
		}

		if prio >= 0 {
			query["priority"] = String(prio)
		}

		do {
			_ = try await API.req(
				type: RestAPILabel.self,
				method: .post,
				endpoint: (id != 0 ? "projects/\(id)/labels" : "groups/\(groupId)/labels"),
				body: query,
				contentType: .formUrlEncoded
			)

			dismiss()
		} catch let error {
			Notify.status(
				.error,
				"Couldn't create Label",
				error.localizedDescription,
				systemImage: "exclamationmark.triangle"
			)
		}
	}

	public var body: some View {
		List {
			Section("Title") {
				TextField("enhancement", text: $title)
			}

			Section("Description (optional)") {
				HighlightedTextEditor(text: $description, highlightRules: .markdown)
					.frame(minHeight: 100)
			}

			Section {
				ColorPicker("Background color", selection: $color)
				Stepper("Priority: \(prio < 0 ? "none" : String(prio))", value: $prio)
			}
		}.toolbar {
			AsyncButton("Save", lucide: .check) {
				await saveNewLabel()
			}.tint(.accentColor)
		}.navigationBarTitle("New Label")
	}
}

#Preview {
	NavigationStack {
		NewLabelView(id: 33_025_310, groupId: 0)
	}
}
