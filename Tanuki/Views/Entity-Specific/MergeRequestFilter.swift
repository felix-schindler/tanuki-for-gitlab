//
//  MergeRequestFilter.swift
//  Tanuki
//
//  Created by Felix Schindler on 08.10.26.
//

import Foundation
import GitLabAPI
import SwiftUI

struct MergeRequestFilter: Equatable {
	var search: String?
	var state: MergeRequestState = .opened
	var draft: Bool?
	var subscribed: SubscriptionStatus?

	var labels: String = ""
	var milestone: String = ""
	var authorUsername: String = ""
	var assigneeUsername: String = ""
	var reviewerUsername: String = ""
	var createdAfter: Foundation.Date?
	var createdBefore: Foundation.Date?
	var updatedAfter: Foundation.Date?
	var updatedBefore: Foundation.Date?
	var includeSubgroups = false

	var labelNames: [String?]? {
		Self.list(labels)
	}

	var milestoneTitle: String? {
		Self.trimmed(milestone)
	}

	var author: String? {
		Self.trimmed(authorUsername)
	}

	var assignee: String? {
		Self.trimmed(assigneeUsername)
	}

	var reviewer: String? {
		Self.trimmed(reviewerUsername)
	}

	private static func list(_ value: String) -> [String?]? {
		let items =
			value
			.split(separator: ",")
			.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
			.filter { $0.isNotEmpty }
		return items.isEmpty ? nil : items
	}

	private static func trimmed(_ value: String) -> String? {
		let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
		return trimmed.isEmpty ? nil : trimmed
	}
}

struct MergeRequestFilterView: View {
	@Binding
	public var filter: MergeRequestFilter

	/// User-scoped lists already pin the author, assignee and reviewer.
	public var showsPeople = true

	/// Group lists can include merge requests from subgroups.
	public var showsScope = false

	public var body: some View {
		FilterSheet(
			filters: $filter,
			initialValue: MergeRequestFilter(search: filter.search)
		) {
			Section("State") {
				Picker("State", selection: self.$filter.state) {
					Text("All").tag(MergeRequestState.all)
					Text("Opened").tag(MergeRequestState.opened)
					Text("Closed").tag(MergeRequestState.closed)
					Text("Locked").tag(MergeRequestState.locked)
					Text("Merged").tag(MergeRequestState.merged)
				}
			}

			Section {
				Picker("Draft", selection: self.$filter.draft) {
					Text("All").tag(nil as Bool?)
					Text("Only drafts").tag(true)
					Text("Exclude drafts").tag(false)
				}
				Picker("Subscribed", selection: self.$filter.subscribed) {
					Text("All")
						.tag(nil as SubscriptionStatus?)
					Text("Explicitly subscribed")
						.tag(SubscriptionStatus.explicitlySubscribed)
					Text("Explicitly unsubscribed")
						.tag(SubscriptionStatus.explicitlyUnsubscribed)
				}
			}

			if showsPeople {
				Section("People") {
					TextField("Author username", text: self.$filter.authorUsername)
						.textInputAutocapitalization(.never)
						.autocorrectionDisabled()
					TextField("Assignee username", text: self.$filter.assigneeUsername)
						.textInputAutocapitalization(.never)
						.autocorrectionDisabled()
					TextField("Reviewer username", text: self.$filter.reviewerUsername)
						.textInputAutocapitalization(.never)
						.autocorrectionDisabled()
				}
			}

			Section("Labels & Milestone") {
				TextField("Labels (comma-separated)", text: self.$filter.labels)
					.textInputAutocapitalization(.never)
					.autocorrectionDisabled()
				TextField("Milestone", text: self.$filter.milestone)
					.textInputAutocapitalization(.never)
					.autocorrectionDisabled()
			}

			Section("Dates") {
				OptionalDatePicker("Created after", date: self.$filter.createdAfter)
				OptionalDatePicker("Created before", date: self.$filter.createdBefore)
				OptionalDatePicker("Updated after", date: self.$filter.updatedAfter)
				OptionalDatePicker("Updated before", date: self.$filter.updatedBefore)
			}

			if showsScope {
				Section("Scope") {
					Toggle("Include subgroups", isOn: self.$filter.includeSubgroups)
				}
			}
		}
	}
}

#Preview {
	MergeRequestFilterView(filter: .constant(MergeRequestFilter()))
}
