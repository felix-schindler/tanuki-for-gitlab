//
//  MergeRequestFilter.swift
//  Tanuki
//
//  Created by Felix Schindler on 08.10.26.
//

import GitLabAPI
import SwiftUI

struct MergeRequestFilter {
	var search: String?
	var state: MergeRequestState = .opened
	var draft: Bool?
	var subscribed: SubscriptionStatus?
}

struct MergeRequestFilterView: View {
	@Binding
	public var filter: MergeRequestFilter

	public var body: some View {
		Form {
			Section {
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
		}
		.navigationBarTitleDisplayMode(.inline)
		.navigationTitle("Merge Requests Filter")
	}
}

#Preview {
	MergeRequestFilterView(filter: .constant(MergeRequestFilter()))
}
