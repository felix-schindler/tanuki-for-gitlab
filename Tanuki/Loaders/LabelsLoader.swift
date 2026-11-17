//
//  GroupLabelsLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 07.03.24.
//

import GitLabAPI
import SwiftUI
import TanukiShared

enum LabelQueryType {
	case group,
		project
}

struct LabelsLoader: View {
	private let id: Int
	private let fullPath: String
	private let queryType: LabelQueryType

	@State
	private var groupPager = PagedQuery<GroupLabelsQuery, MyLabel>(
		extract: { ($0.group?.labels?.nodes ?? []).compactMap { $0 } },
		key: { $0.id },
		hasNext: { $0.group?.labels?.pageInfo.hasNextPage ?? false },
		endCursor: { $0.group?.labels?.pageInfo.endCursor }
	)

	@State
	private var projectPager = PagedQuery<ProjectLabelsQuery, MyLabel>(
		extract: { ($0.project?.labels?.nodes ?? []).compactMap { $0 } },
		key: { $0.id },
		hasNext: { $0.project?.labels?.pageInfo.hasNextPage ?? false },
		endCursor: { $0.project?.labels?.pageInfo.endCursor }
	)

	init(fullPath: String, id: Int, queryType: LabelQueryType) {
		self.fullPath = fullPath
		self.id = id
		self.queryType = queryType
	}

	private var state: Loadable<[MyLabel]> {
		switch queryType {
		case .group: groupPager.state
		case .project: projectPager.state
		}
	}

	private var hasMore: Bool {
		switch queryType {
		case .group: groupPager.hasMore
		case .project: projectPager.hasMore
		}
	}

	private func load() async {
		switch queryType {
		case .group:
			await groupPager.start(
				GroupLabelsQuery(first: 50, after: .none, fullPath: fullPath),
				setCursor: { $0.after = .some($1) })
		case .project:
			await projectPager.start(
				ProjectLabelsQuery(first: 50, after: .none, fullPath: fullPath),
				setCursor: { $0.after = .some($1) })
		}
	}

	private func refresh() async {
		switch queryType {
		case .group: await groupPager.refresh()
		case .project: await projectPager.refresh()
		}
	}

	private func loadMore() async {
		switch queryType {
		case .group: await groupPager.loadMore()
		case .project: await projectPager.loadMore()
		}
	}

	public var body: some View {
		LoadableList(
			state,
			hasMore: hasMore,
			emptyMessage: "There are no labels",
			emptySystemImage: Icons.tag.rawValue,
			loadingMessage: "Loading Labels",
			loadingSystemImage: Icons.tag.rawValue,
			onLoadMore: { await loadMore() },
			onRefresh: { await refresh() }
		) { label in
			VStack(alignment: .leading) {
				ScrollView(.horizontal) {
					PillView(
						label.title.emojized(),
						bgColor: Color(hex: label.color),
						fgColor: Color(hex: label.textColor)
					)
				}

				if let description = label.description, description.isNotEmpty {
					Markdown(description)
				}
			}
		}.task {
			await load()
		}.toolbar {
			if self.state.value != nil {
				NavigationLink(
					destination: {
						if self.queryType == .project {
							NewLabelView(id: self.id, groupId: 0)
						} else {
							NewLabelView(id: 0, groupId: self.id)
						}
					},
					label: {
						Label("New label", systemImage: "plus")
					}
				).tint(.accentColor)
			}
		}.navigationTitle("Labels")
	}
}

#Preview {
	NavigationStack {
		LabelsLoader(fullPath: "gitlab-org", id: 278_964, queryType: .group)
	}
}
