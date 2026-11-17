//
//  EventsView.swift
//  GitLab
//
//  Created by Felix Schindler on 31.10.21.
//

import SwiftUI
import TanukiShared

struct EventsLoader: View {
	private var projectId = 0
	private var userId = 0

	@State
	private var state = Loadable<[Event]>()

	@State
	private var pager = RestPage()

	init() {
	}

	init(userId: Int) {
		self.userId = userId
	}

	init(projectId: Int) {
		self.projectId = projectId
	}

	private func getStupidText(event: Event) -> String {
		var ret = event.actionName.capitalized
		if let targetType = event.targetType {
			ret += " \(targetType)"
		}
		if let targetIid = event.targetIid {
			ret += " \(targetIid)"
		}
		if let targetTitle = event.targetTitle?.emojized() {
			ret += " '\(targetTitle)'"
		}
		if let pushData = event.pushData {
			ret += " \(pushData.refType) '\(pushData.ref)'"
			if let commitTitle = pushData.commitTitle?.emojized() {
				ret += " with message '\(commitTitle)'"
			}
		}
		if ret == event.actionName.capitalized {
			ret += " project \(event.projectId)"
		}
		return ret.trimmingCharacters(in: .whitespacesAndNewlines)
	}

	private var endpoint: String {
		if projectId != 0 {
			return "projects/\(projectId)/events"
		} else if userId != 0 {
			return "users/\(userId)/events"
		}
		return "events"
	}

	private func load(reset: Bool) async {
		if reset {
			pager.reset()
			state.isLoading = true
		} else {
			state.isLoadingMore = true
		}

		defer {
			state.isLoading = false
			state.isLoadingMore = false
		}

		do {
			let events = try await API.get(
				type: [Event].self, endpoint: endpoint, query: pager.query)

			if Task.isCancelled { return }
			state.value = reset ? events : (state.value ?? []) + events
			state.error = nil
			pager.advance(events.count)
		} catch {
			if Task.isCancelled { return }
			state.error = error
			Notify.status(.error)
		}
	}

	private func loadMore() async {
		guard pager.hasMore, !state.isLoading, !state.isLoadingMore else { return }
		await load(reset: false)
	}

	public var body: some View {
		LoadableList(
			state,
			hasMore: pager.hasMore,
			emptyMessage: "There are no events",
			emptySystemImage: "clock.arrow.circlepath",
			loadingMessage: "Loading events",
			loadingSystemImage: Icons.events.rawValue,
			onLoadMore: { await loadMore() },
			onRefresh: { await load(reset: true) },
			row: { event in
				VStack(alignment: .leading) {
					ScrollView(.horizontal) {
						HStack {
							AuthorView(event.author)
							PillView(
								event.createdAt.toString(timeStyle: .short), icon: Icons.clock.rawValue)
						}
					}.font(.footnote)
					Text(getStupidText(event: event))
				}
			}
		).task {
			await load(reset: true)
		}.navigationTitle("Activity")
	}
}

#Preview {
	NavigationStack {
		EventsLoader()
	}
}
