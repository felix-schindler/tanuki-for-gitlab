//
//  VotePillsView.swift
//  Tanuki
//

import Alamofire
import SwiftUI

enum AwardableType {
	case issue
	case mergeRequest

	var path: String {
		switch self {
		case .issue:
			"issues"
		case .mergeRequest:
			"merge_requests"
		}
	}
}

struct VotePillsView: View {
	let projectId: Int?
	let iid: String
	let type: AwardableType
	let upvotes: Int
	let downvotes: Int
	var onVoted: () async -> Void = {}

	private func vote(_ name: String) async {
		guard let projectId else { return }
		do {
			_ = try await API.raw(
				method: .post,
				endpoint: "projects/\(projectId)/\(type.path)/\(iid)/award_emoji",
				body: ["name": EncodableValue.string(name)]
			)
			await onVoted()
		} catch {
			Notify.status(.error, "Failed to vote", error.localizedDescription)
		}
	}

	var body: some View {
		HStack {
			Button {
				Task { await vote("thumbsup") }
			} label: {
				PillView(String(upvotes), icon: "hand.thumbsup")
			}
			Button {
				Task { await vote("thumbsdown") }
			} label: {
				PillView(String(downvotes), icon: "hand.thumbsdown")
			}
		}
		.buttonStyle(.plain)
		.disabled(projectId == nil)
	}
}
