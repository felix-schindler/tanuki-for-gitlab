//
//  NewMilestoneView.swift
//  Tanuki
//
//  Created by Felix Schindler on 21.09.25.
//

import HighlightedTextEditor
import SwiftUI

struct NewMilestoneView: View {
	@Environment(\.dismiss) private var dismiss

	/// Project ID
	@State var id: Int
	/// Group ID
	@State var groupId: Int

	@State var title = ""
	@State var desc = ""

	@State var setDates = true
	@State var startDate = Date()
	@State var dueDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date())!

	private func createMilestone() async {
		if title.isEmpty {
			Notify.status(
				.error,
				"Please enter a title.",
				systemImage: "exclamationmark.triangle"
			)
			return
		}

		var newMilestone = [
			"title": title
		]

		if desc.isNotEmpty {
			newMilestone["description"] = desc
		}

		if setDates {
			let inputFormatter = DateFormatter()
			inputFormatter.dateFormat = "yyyy-MM-dd"

			newMilestone["start_date"] = inputFormatter.string(from: startDate)
			newMilestone["due_date"] = inputFormatter.string(from: dueDate)
		}

		do {
			_ = try await API.req(
				type: RestAPIMilestone.self,
				method: .post,
				endpoint: (id != 0 ? "projects/\(id)/milestones" : "groups/\(groupId)/milestones"),
				body: newMilestone
			)

			self.dismiss()
		} catch let error {
			Notify.status(
				.error,
				"Couldn't create new Milestone",
				error.localizedDescription,
				systemImage: "exclamationmark.triangle"
			)
		}
	}

	public var body: some View {
		Form {
			TextField("Title (required)", text: $title)

			Section("Dates") {
				Toggle("Set dates", isOn: $setDates)

				if setDates {
					DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
					DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
				}
			}

			Section("Description (Markdown supported)") {
				HighlightedTextEditor(text: $desc, highlightRules: .markdown)
					.frame(minHeight: 100)
			}
		}.toolbar {
			AsyncButton("Create milestone", lucide: .check) {
				await createMilestone()
			}.tint(.accentColor)
		}.navigationTitle("New Milestone")
	}
}

#Preview {
	NavigationStack {
		NewMilestoneView(id: 33_025_310, groupId: 0)
	}
}
