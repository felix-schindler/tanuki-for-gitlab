//
//  IssueFilterView.swift
//  Tanuki
//
//  Created by Felix Schindler on 26.10.25.
//

import GitLabAPI
import SwiftUI

struct IssueFilter {
	var search: String?
	var state: IssuableState = .opened
	var types: GitLabAPI.IssueType? = nil
	var confidential: Bool?
	var subscribed: SubscriptionStatus?
}

struct IssueFilterView: View {
	@Binding
	public var filter: IssueFilter

	public var body: some View {
		Form {
			Section {
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
		}
		.navigationBarTitleDisplayMode(.inline)
		.navigationTitle("Projects Filter")
	}
}

#Preview {
	IssueFilterView(filter: .constant(IssueFilter()))
}
