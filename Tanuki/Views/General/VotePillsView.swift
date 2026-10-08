//
//  VotePillsView.swift
//  Tanuki
//
//  Created by Felix Schindler on 08.10.26.
//

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

	private struct AwardEmoji: Codable {
		let id: Int
		let name: String
		let user: UserSmall
	}

	private func vote(_ name: String) async {
		guard let projectId else { return }
		let endpoint = "projects/\(projectId)/\(type.path)/\(iid)/award_emoji"
		do {
			_ = try await API.raw(
				method: .post,
				endpoint: endpoint,
				body: ["name": EncodableValue.string(name)]
			)
			await onVoted()
		} catch {
			await unvote(endpoint: endpoint, name: name, originalError: error)
		}
	}

	private func unvote(endpoint: String, name: String, originalError: Error) async {
		do {
			let me = try await API.get(type: RestAPIUser.self, endpoint: "user")
			let awards = try await API.get(
				type: [AwardEmoji].self, endpoint: endpoint, query: ["per_page": "100"])
			guard let mine = awards.first(where: { $0.name == name && $0.user.id == me.id }) else {
				Notify.status(.error, "Failed to vote", originalError.localizedDescription)
				return
			}
			try await API.delete(endpoint: "\(endpoint)/\(mine.id)")
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
