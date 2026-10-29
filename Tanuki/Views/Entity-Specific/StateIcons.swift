//
//  StateIcons.swift
//  Tanuki
//
//  Created by Felix Schindler on 27.02.24.
//

import GitLabAPI
import SwiftUI

struct IssueStateHelper {
	public static func getColorByState(
		_ state: GraphQLEnum<GitLabAPI.IssueState>
	) -> SwiftUI.Color {
		switch state {
		case .opened:
			Color.green
		case .closed:
			Color.blue
		case .locked:
			Color.secondary
		default:
			Color.primary
		}
	}

	public static func getIconByState(
		_ state: GraphQLEnum<GitLabAPI.IssueState>
	) -> String {
		switch state {
		case .opened:
			"smallcircle.circle"
		case .closed:
			"minus.circle"
		case .locked:
			"lock.circle"
		default:
			"smallcircle.circle"
		}
	}
}

struct IssueStateIcon: View {
	private let state: String
	private let icon: String
	private let color: SwiftUI.Color

	init(_ state: GraphQLEnum<GitLabAPI.IssueState>) {
		self.state = state.rawValue

		switch state {
		case .opened:
			icon = "smallcircle.circle"
			color = Color.green
			break
		case .closed:
			icon = "minus.circle"
			color = Color.blue
			break
		case .locked:
			icon = "lock.circle"
			color = Color.secondary
			break
		default:
			icon = "smallcircle.circle"
			color = Color.primary
			break
		}
	}

	public var body: some View {
		Label(self.state, systemImage: self.icon)
			.foregroundStyle(self.color)
			.labelStyle(.iconOnly)
	}
}

struct MergeStateHelper {
	public static func getColorByState(
		_ state: GraphQLEnum<GitLabAPI.MergeRequestState>
	) -> SwiftUI.Color {
		switch state {
		case .opened:
			return Color.green
		case .merged:
			return Color.blue
		case .closed:
			return Color.red
		case .locked:
			return Color.secondary
		default:
			return Color.primary
		}
	}

	public static func getIconByState(
		_ state: GraphQLEnum<GitLabAPI.MergeRequestState>
	) -> Image {
		switch state {
		case .opened:
			return Image("git-mr.symbols")
		case .merged:
			return Image("git-mr-merged.symbols")
		case .closed:
			return Image("git-mr-closed.symbols")
		case .locked:
			return Image(systemName: "lock")
		default:
			return Image("git-mr.symbols")
		}
	}
}

struct MergeStateIcon: View {
	private let state: GraphQLEnum<GitLabAPI.MergeRequestState>
	private let icon: Image
	private let color: SwiftUI.Color

	init(_ state: GraphQLEnum<GitLabAPI.MergeRequestState>) {
		self.state = state
		self.icon = MergeStateHelper.getIconByState(state)
		self.color = MergeStateHelper.getColorByState(state)
	}

	public var body: some View {
		Label(
			title: {
				Text(self.state.rawValue)
			},
			icon: {
				self.icon
			}
		)
		.foregroundStyle(self.color)
		.labelStyle(.iconOnly)
	}
}

struct MergeStatus: View {
	private let status: GraphQLEnum<GitLabAPI.MergeStatus>
	private let icon: String
	private let color: SwiftUI.Color
	private let msg: String

	init(_ status: GraphQLEnum<GitLabAPI.MergeStatus>) {
		self.status = status

		switch status {
		case .canBeMerged:
			self.msg = "There are no conflicts between the source and target branches."
			self.icon = "checkmark"
			self.color = Color.green
		case .cannotBeMerged:
			self.msg = "There are conflicts between the source and target branches."
			self.icon = "xmark"
			self.color = Color.red
		case .checking:
			self.msg = "Currently checking for mergeability."
			self.icon = "arrow.2.circlepath"
			self.color = Color.orange
		case .unchecked:
			self.msg = "Merge status has not been checked."
			self.icon = "questionmark"
			self.color = Color.secondary
		case .cannotBeMergedRecheck:
			self.msg = "Currently unchecked. The previous state was `CANNOT_BE_MERGED`."
			self.icon = "questionmark"
			self.color = Color.secondary
		default:
			self.msg = ""
			self.icon = "questionmark"
			self.color = Color.primary
		}
	}

	public var body: some View {
		Label(
			title: {
				VStack(alignment: .leading) {
					Text(
						self.status.rawValue
							.split(separator: "_")
							.joined(separator: " ")
							.lowercased()
							.capitalized
					)
					if self.msg.isNotEmpty {
						Text(self.msg)
							.foregroundStyle(.secondary)
					}
				}
			},
			icon: {
				Image(systemName: self.icon)
			}
		).foregroundStyle(self.color)
	}
}

struct DetailedMergeStatusView: View {
	private var msg: String

	init(_ detailedStatus: GraphQLEnum<GitLabAPI.DetailedMergeStatus>) {
		msg =
			switch detailedStatus {
			case .unchecked:
				"Merge status has not been checked."
			case .checking:
				"Currently checking for mergeability."
			case .mergeable:
				"Branch can be merged."
			case .commitsStatus:
				"Source branch exists and contains commits."
			case .ciMustPass:
				"Pipeline must succeed before merging."
			case .ciStillRunning:
				"Pipeline is still running."
			case .discussionsNotResolved:
				"Discussions must be resolved before merging."
			case .draftStatus:
				"Merge request must not be draft before merging."
			case .notOpen:
				"Merge request must be open before merging."
			case .notApproved:
				"Merge request must be approved before merging."
			case .blockedStatus:
				"Merge request dependencies must be merged."
			case .externalStatusChecks:
				"Status checks must pass."
			case .preparing:
				"Merge request diff is being created."
			case .jiraAssociation:
				"Either the title or description must reference a Jira issue."
			case .conflict:
				"There are conflicts between the source and target branches."
			case .needRebase:
				"Merge request needs to be rebased."
			default:
				"Unknown error"
			}
	}

	public var body: some View {
		Label(
			title: {
				Text(msg)
			},
			icon: {
				Image(systemName: "minus.circle.fill")
					.foregroundStyle(.red)
			}
		)
	}
}

#Preview {
	ScrollView {
		VStack {
			HStack {
				VStack {
					ForEach(GraphQLEnum<GitLabAPI.IssueState>.allCases, id: \.self) {
						state in
						IssueStateIcon(state)
					}
				}
				VStack {
					ForEach(
						GraphQLEnum<GitLabAPI.MergeRequestState>.allCases, id: \.self
					) { state in
						MergeStateIcon(state)
					}
				}
				VStack {
					ForEach(GraphQLEnum<GitLabAPI.MergeStatus>.allCases, id: \.self) {
						status in
						MergeStatus(status)
					}
				}
			}

			VStack {
				ForEach(GraphQLEnum<GitLabAPI.DetailedMergeStatus>.allCases, id: \.self) { status in
					DetailedMergeStatusView(status)
				}
			}
		}
	}
}
