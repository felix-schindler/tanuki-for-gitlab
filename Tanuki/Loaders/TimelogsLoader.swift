//
//  TimelogsLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 07.03.24.
//

import GitLabAPI
import SwiftUI
import TanukiShared

enum TimelogsQueryType {
	case group,
		user
}

struct TimelogsLoader: View {
	private let fullPath: String
	private let queryType: TimelogsQueryType

	@State
	private var groupPager = PagedQuery<GroupTimelogsQuery, Timelog>(
		extract: { ($0.group?.timelogs.nodes ?? []).compactMap { $0 } },
		key: { $0.id },
		hasNext: { $0.group?.timelogs.pageInfo.hasNextPage ?? false },
		endCursor: { $0.group?.timelogs.pageInfo.endCursor }
	)

	@State
	private var userPager = PagedQuery<UserTimelogsQuery, Timelog>(
		extract: { ($0.user?.timelogs?.nodes ?? []).compactMap { $0 } },
		key: { $0.id },
		hasNext: { $0.user?.timelogs?.pageInfo.hasNextPage ?? false },
		endCursor: { $0.user?.timelogs?.pageInfo.endCursor }
	)

	init(fullPath: String, queryType: TimelogsQueryType) {
		self.fullPath = fullPath
		self.queryType = queryType
	}

	private var state: Loadable<[Timelog]> {
		switch queryType {
		case .group: groupPager.state
		case .user: userPager.state
		}
	}

	private var hasMore: Bool {
		switch queryType {
		case .group: groupPager.hasMore
		case .user: userPager.hasMore
		}
	}

	private func load() async {
		switch queryType {
		case .group:
			await groupPager.start(
				GroupTimelogsQuery(first: 50, after: .none, fullPath: fullPath),
				setCursor: { $0.after = .some($1) })
		case .user:
			await userPager.start(
				UserTimelogsQuery(first: 50, after: .none, username: fullPath),
				setCursor: { $0.after = .some($1) })
		}
	}

	private func refresh() async {
		switch queryType {
		case .group: await groupPager.refresh()
		case .user: await userPager.refresh()
		}
	}

	private func loadMore() async {
		switch queryType {
		case .group: await groupPager.loadMore()
		case .user: await userPager.loadMore()
		}
	}

	public var body: some View {
		LoadableList(
			state,
			id: \.id,
			hasMore: hasMore,
			emptyMessage: "There are no timelogs",
			emptySystemImage: Icons.timeTracking.rawValue,
			loadingMessage: "Loading Timelogs",
			loadingSystemImage: Icons.timeTracking.rawValue,
			onLoadMore: { await loadMore() },
			onRefresh: { await refresh() }
		) { log in
			VStack(alignment: .leading) {

				ScrollView(.horizontal) {
					HStack {
						NavigationLink(
							destination: ProjectLoader(fullPath: log._project.fullPath),
							label: {
								Label(
									log._project.nameWithNamespace,
									systemImage: Icons.projects.rawValue)
							}
						)
						.controlSize(.mini)
						.buttonBorderShape(.capsule)
						.adaptiveButtonStyle()

						AuthorView(log._user)

						if let spentAt = log.spentAt {
							PillView(Date.fromToString(spentAt), icon: Icons.clock.rawValue)
						}

						if let issueIid = log._issue?.iid {
							NavigationLink(
								destination: IssueLoader(
									fullPath: log._project.fullPath,
									iid: issueIid
								),
								label: {
									Label("#\(issueIid)", systemImage: Icons.issues.rawValue)
								}
							)
							.controlSize(.mini)
							.buttonBorderShape(.capsule)
							.adaptiveButtonStyle()
						}

						if let mergeIid = log._mergeRequest?.iid {
							NavigationLink(
								destination: MergeRequestLoader(
									fullPath: log._project.fullPath,
									iid: mergeIid
								),
								label: {
									Label("!\(mergeIid)", systemImage: "arrow.triangle.pull")
								}
							)
							.controlSize(.mini)
							.buttonBorderShape(.capsule)
							.adaptiveButtonStyle()
						}
					}.font(.footnote)
				}

				PillView("\(log.timeSpent / 60) minutes", icon: Icons.clock.rawValue)
					.font(.footnote)

				if let summary = log.summary, summary.isNotEmpty {
					Markdown(summary)
				}
			}
		}.task {
			await load()
		}.navigationTitle("Timelogs")
	}
}

#Preview {
	NavigationStack {
		TimelogsLoader(fullPath: "felix-schindler", queryType: .user)
	}
}
