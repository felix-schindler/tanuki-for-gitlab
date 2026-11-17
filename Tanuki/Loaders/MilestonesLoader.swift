//
//  GroupMilestonesLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 07.03.24.
//

import GitLabAPI
import SwiftUI
import TanukiShared

enum MilestoneQueryType {
	case group,
		project
}

struct MilestonesLoader: View {
	private let id: Int
	private let fullPath: String
	private let queryType: MilestoneQueryType

	@State
	private var groupPager = PagedQuery<GroupMilestonesQuery, Milestone>(
		extract: { ($0.group?.milestones?.nodes ?? []).compactMap { $0 } },
		key: { $0.iid },
		hasNext: { $0.group?.milestones?.pageInfo.hasNextPage ?? false },
		endCursor: { $0.group?.milestones?.pageInfo.endCursor }
	)

	@State
	private var projectPager = PagedQuery<ProjectMilestonesQuery, Milestone>(
		extract: { ($0.project?.milestones?.nodes ?? []).compactMap { $0 } },
		key: { $0.iid },
		hasNext: { $0.project?.milestones?.pageInfo.hasNextPage ?? false },
		endCursor: { $0.project?.milestones?.pageInfo.endCursor }
	)

	@State
	private var showFilters = false

	// MARK: - Filter
	@State private var searchTitle: String? = nil
	@State private var state: MilestoneStateEnum? = .active
	@State private var includeAncestors = false

	init(fullPath: String, id: Int, queryType: MilestoneQueryType) {
		self.fullPath = fullPath
		self.id = id
		self.queryType = queryType
	}

	private func groupQuery(after: GraphQLNullable<String> = .none) -> GroupMilestonesQuery {
		return GroupMilestonesQuery(
			first: 50,
			after: after,
			fullPath: self.fullPath,
			state: GraphFilter.toFilterEnum(self.state),
			searchTitle: GraphFilter.toFilter(self.searchTitle),
			includeAncestors: .some(self.includeAncestors)
		)
	}

	private func projectQuery(after: GraphQLNullable<String> = .none) -> ProjectMilestonesQuery {
		return ProjectMilestonesQuery(
			first: 50,
			after: after,
			fullPath: self.fullPath,
			state: GraphFilter.toFilterEnum(self.state),
			searchTitle: GraphFilter.toFilter(self.searchTitle),
			includeAncestors: .some(self.includeAncestors)
		)
	}

	private var loadState: Loadable<[Milestone]> {
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
			await groupPager.start(groupQuery(), setCursor: { $0.after = .some($1) })
		case .project:
			await projectPager.start(projectQuery(), setCursor: { $0.after = .some($1) })
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
			loadState,
			hasMore: hasMore,
			emptyMessage: "There are no milestones",
			emptySystemImage: Icons.milestones.rawValue,
			loadingMessage: "Loading Milestones",
			loadingSystemImage: Icons.milestones.rawValue,
			onLoadMore: { await loadMore() },
			onRefresh: { await refresh() }
		) { milestone in
			VStack(alignment: .leading, spacing: 10) {
				Label(
					title: {
						Text(milestone.title.emojized())
					},
					icon: {
						Image(systemName: Icons.milestones.rawValue)
							.foregroundStyle(
								milestone.state == .closed
									? .red
									: (milestone.expired
										? .orange
										: .green)
							)
					}
				)

				if let description = milestone.description, description.isNotEmpty {
					Markdown(description)
				}
			}
		}.debouncedLoad(searchTitle) {
			await load()
		}.searchable(
			text: Binding(get: { self.searchTitle ?? "" }, set: { self.searchTitle = $0.isNotEmpty ? $0 : nil }),
			prompt: "Title"
		).toolbar {
			HStack {
				Button("Filter", systemImage: Icons.filter.rawValue) {
					showFilters = true
				}
				NavigationLink(
					destination: {
						if self.queryType == .project {
							NewMilestoneView(id: self.id, groupId: 0)
						} else {
							NewMilestoneView(id: 0, groupId: self.id)
						}
					},
					label: {
						Label("Create new milestone", systemImage: "plus")
					}
				).tint(.accentColor)
			}
		}.sheet(isPresented: $showFilters, onDismiss: { self.showFilters = false }) {
			NavigationStack {
				Form {
					Picker("State", selection: $state) {
						Text("Any").tag(nil as MilestoneStateEnum?)
						ForEach(MilestoneStateEnum.allCases, id: \.self) { state in
							Text(state.rawValue.capitalized).tag(state)
						}
					}
					VStack(alignment: .leading) {
						Toggle("Include Ancestors", isOn: $includeAncestors)
						Text("Also return milestones in the project's parent group and its ancestors.")
							.foregroundStyle(.secondary)
							.font(.footnote)
					}
				}.toolbar {
					AsyncButton("Apply filter", systemImage: "checkmark") {
						await load()
						showFilters = false
					}
				}
				.navigationBarTitleDisplayMode(.inline)
				.navigationTitle("Milestones Filter")
			}
		}.navigationTitle("Milestones")
	}
}

#Preview {
	NavigationStack {
		MilestonesLoader(fullPath: "gitlab-org", id: 278_964, queryType: .group)
	}
}
