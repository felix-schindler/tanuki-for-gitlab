//
//  StateIcons.swift
//  Tanuki
//
//  Created by Felix Schindler on 27.02.24.
//

import GitLabAPI
import Lucide
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
	) -> LucideIcon {
		switch state {
		case .opened:
			.circleDot
		case .closed:
			.circleMinus
		case .locked:
			.lock
		default:
			.circleDot
		}
	}
}

struct IssueStateIcon: View {
	private let state: String
	private let icon: LucideIcon
	private let color: SwiftUI.Color

	init(_ state: GraphQLEnum<GitLabAPI.IssueState>) {
		self.state = state.rawValue

		switch state {
		case .opened:
			icon = .circleDot
			color = Color.green
			break
		case .closed:
			icon = .circleMinus
			color = Color.blue
			break
		case .locked:
			icon = .lock
			color = Color.secondary
			break
		default:
			icon = .circleDot
			color = Color.primary
			break
		}
	}

	public var body: some View {
		Label(self.state, lucide: self.icon)
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
	) -> LucideIcon {
		switch state {
		case .opened:
			return .gitPullRequest
		case .merged:
			return .gitMerge
		case .closed:
			return .gitPullRequestClosed
		case .locked:
			return .lock
		default:
			return .gitPullRequest
		}
	}
}

struct MergeStateIcon: View {
	private let state: GraphQLEnum<GitLabAPI.MergeRequestState>
	private let icon: LucideIcon
	private let color: SwiftUI.Color

	init(_ state: GraphQLEnum<GitLabAPI.MergeRequestState>) {
		self.state = state
		self.icon = MergeStateHelper.getIconByState(state)
		self.color = MergeStateHelper.getColorByState(state)
	}

	public var body: some View {
		Label(self.state.rawValue, lucide: self.icon)
			.foregroundStyle(self.color)
			.labelStyle(.iconOnly)
	}
}

struct MergeStatus: View {
	private let status: GraphQLEnum<GitLabAPI.MergeStatus>
	private let icon: LucideIcon
	private let color: SwiftUI.Color
	private let msg: String

	init(_ status: GraphQLEnum<GitLabAPI.MergeStatus>) {
		self.status = status

		switch status {
		case .canBeMerged:
			self.msg = "There are no conflicts between the source and target branches."
			self.icon = .check
			self.color = Color.green
		case .cannotBeMerged:
			self.msg = "There are conflicts between the source and target branches."
			self.icon = .x
			self.color = Color.red
		case .checking:
			self.msg = "Currently checking for mergeability."
			self.icon = .refreshCw
			self.color = Color.orange
		case .unchecked:
			self.msg = "Merge status has not been checked."
			self.icon = .circleQuestionMark
			self.color = Color.secondary
		case .cannotBeMergedRecheck:
			self.msg = "Currently unchecked. The previous state was `CANNOT_BE_MERGED`."
			self.icon = .circleQuestionMark
			self.color = Color.secondary
		default:
			self.msg = ""
			self.icon = .circleQuestionMark
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
				LucideLabelIcon(self.icon)
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
		Label(msg, lucide: .circleMinus, color: .red)
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
