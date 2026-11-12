//
//  IssueFilterView.swift
//  Tanuki
//
//  Created by Felix Schindler on 26.10.25.
//

import Foundation
import GitLabAPI
import SwiftUI

struct IssueFilter: Equatable {
	var search: String?
	var state: IssuableState = .opened
	var types: GitLabAPI.IssueType? = nil
	var confidential: Bool?
	var subscribed: SubscriptionStatus?

	var labels: String = ""
	var milestones: String = ""
	var authorUsername: String = ""
	var assigneeUsernames: String = ""
	var createdAfter: Foundation.Date?
	var createdBefore: Foundation.Date?
	var updatedAfter: Foundation.Date?
	var updatedBefore: Foundation.Date?
	var includeSubgroups = false

	var labelNames: [String?]? {
		Self.list(labels)
	}

	var milestoneTitles: [String?]? {
		Self.list(milestones)
	}

	var author: String? {
		Self.trimmed(authorUsername)
	}

	var assignees: [String]? {
		Self.list(assigneeUsernames)?.compactMap { $0 }
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

struct IssueFilterView: View {
	@Binding
	public var filter: IssueFilter

	/// User-scoped lists already pin the author and assignee, so hide those fields.
	public var showsPeople = true

	/// Group lists can include issues from subgroups.
	public var showsScope = false

	public var body: some View {
		FilterSheet(
			filters: $filter,
			initialValue: IssueFilter(search: filter.search)
		) {
			Section("State") {
				Picker("State", selection: self.$filter.state) {
					Text("All").tag(IssuableState.all)
					Text("Opened").tag(IssuableState.opened)
					Text("Closed").tag(IssuableState.closed)
					Text("Locked").tag(IssuableState.locked)
				}
				Picker("Types", selection: self.$filter.types) {
					Text("All").tag(nil as GitLabAPI.IssueType?)
					ForEach(GitLabAPI.IssueType.allCases, id: \.self) { type in
						Text(type.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
							.tag(type)
					}
				}
			}

			Section {
				Picker("Confidential", selection: self.$filter.confidential) {
					Text("All").tag(nil as Bool?)
					Text("Only confidential").tag(true)
					Text("Exclude confidential").tag(false)
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
					TextField("Assignee username", text: self.$filter.assigneeUsernames)
						.textInputAutocapitalization(.never)
						.autocorrectionDisabled()
				}
			}

			Section("Labels & Milestones") {
				TextField("Labels (comma-separated)", text: self.$filter.labels)
					.textInputAutocapitalization(.never)
					.autocorrectionDisabled()
				TextField("Milestones (comma-separated)", text: self.$filter.milestones)
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
	IssueFilterView(filter: .constant(IssueFilter()))
}
