//
//  EventsView.swift
//  GitLab
//
//  Created by Felix Schindler on 31.10.21.
//

import SwiftUI

struct EventsLoader: View {
	private var projectId = 0
	private var userId = 0

	@State
	private var events: Result<[Event], Error>? = nil

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

	private func getEvents() async {
		var endpoint: String

		if projectId != 0 {
			endpoint = "projects/\(projectId)/events"
		} else if userId != 0 {
			endpoint = "users/\(userId)/events"
		} else {
			endpoint = "events"
		}

		do {
			let events = try await API.get(type: [Event].self, endpoint: endpoint)
			self.events = .success(events)
		} catch let error {
			self.events = .failure(error)
		}
	}

	public var body: some View {
		List {
			if let events {
				switch events {
				case .success(let events):
					if events.isEmpty {
						NoContentView("There are no events", lucide: .activity)
					} else {
						ForEach(events, id: \.id) { event in
							VStack(alignment: .leading) {
								ScrollView(.horizontal) {
									HStack {
										AuthorView(event.author)
										PillView(event.createdAt.toString(timeStyle: .short), icon: .clock)
									}
								}.font(.footnote)
								Text(getStupidText(event: event))
							}
						}
					}
				case .failure(let failure):
					FailedView(failure.localizedDescription)
				}
			} else {
				LoadingView("Loading events", lucide: .bell)
			}
		}.task {
			await getEvents()
		}.refreshable {
			await getEvents()
		}.navigationTitle("Activity")
	}
}

#Preview {
	NavigationStack {
		EventsLoader()
	}
}
