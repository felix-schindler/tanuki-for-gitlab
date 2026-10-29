//
//  NewMergeRequestView.swift
//  Tanuki
//
//  Created by Felix Schindler on 08.10.26.
//

import HighlightedTextEditor
import SwiftUI

struct NewMergeRequestView: View {
	@Environment(\.dismiss) private var dismiss

	private let id: Int
	private let targetBranch: String

	init(id: Int, targetBranch: String = "main") {
		self.id = id
		self.targetBranch = targetBranch
	}

	@State private var title = ""
	@State private var description = ""
	@State private var sourceBranch = ""
	@State private var target: String = ""
	@State private var removeSourceBranch = true

	private func createMergeRequest() async {
		guard title.isNotEmpty else {
			Notify.status(.error, "Please enter a title.")
			return
		}
		guard sourceBranch.isNotEmpty else {
			Notify.status(.error, "Please enter a source branch.")
			return
		}
		var body: [String: EncodableValue] = [
			"title": .string(title),
			"source_branch": .string(sourceBranch),
			"target_branch": .string(target.isEmpty ? targetBranch : target),
		]
		if description.isNotEmpty {
			body["description"] = .string(description)
		}
		if removeSourceBranch {
			body["remove_source_branch"] = .boolean(true)
		}
		do {
			let mr = try await API.req(
				type: RestAPIMergeRequest.self,
				method: .post,
				endpoint: "projects/\(id)/merge_requests",
				body: body
			)
			Notify.status(.success, "Merge request !\(mr.iid) created")
			dismiss()
		} catch {
			Notify.status(.error, "Failed to create merge request", error.localizedDescription)
		}
	}

	var body: some View {
		Form {
			TextField("Title (required)", text: $title)
			TextField("Source branch (required)", text: $sourceBranch)
				.autocorrectionDisabled()
				.textInputAutocapitalization(.never)
			TextField("Target branch", text: $target)
				.autocorrectionDisabled()
				.textInputAutocapitalization(.never)
			Section("Description (Markdown supported)") {
				HighlightedTextEditor(text: $description, highlightRules: .markdown)
					.frame(minHeight: 100)
			}
			Toggle("Remove source branch on merge", isOn: $removeSourceBranch)
		}.toolbar {
			AsyncButton("Create merge request", lucide: .check) {
				await createMergeRequest()
			}.tint(.accentColor)
		}
		.navigationTitle("New Merge Request")
		.scrollDismissesKeyboard(.interactively)
		.onAppear { target = targetBranch }
	}
}

#Preview {
	NavigationStack {
		NewMergeRequestView(id: 278_964)
	}
}
