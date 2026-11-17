//
//  ProjectsLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 11.10.25.
//

import GitLabAPI
import SwiftUI
import TanukiShared

struct ProjectsLoader: View {
	@State
	private var pager = PagedQuery<ProjectsQuery, SmallProject>(
		extract: { ($0.projects?.nodes ?? []).compactMap { $0 } },
		key: { $0.fullPath },
		hasNext: { $0.projects?.pageInfo.hasNextPage ?? false },
		endCursor: { $0.projects?.pageInfo.endCursor }
	)

	@State
	private var showFilters = false

	// MARK: - Filter
	@State public private(set) var search: String? = nil
	@State public private(set) var membership: Bool = false
	@State public private(set) var personal: Bool = false
	@State public private(set) var withIssuesEnabled: Bool = false
	@State public private(set) var withMergeRequestsEnabled: Bool = false
	@State public private(set) var archived: ProjectArchived = .include
	@State public private(set) var accessLevel: AccessLevelEnum? = nil
	@State public private(set) var aimedForDeletion: Bool = false
	@State public private(set) var notAimedForDeletion: Bool = true
	@State public private(set) var markedForDeletionOn: SwiftUI.Date? = nil
	@State public private(set) var active: Bool? = nil

	private func query(after: GraphQLNullable<String> = .none) -> ProjectsQuery {
		return ProjectsQuery(
			first: 50,
			after: after,
			membership: .some(self.membership),
			search: GraphFilter.toFilter(self.search),
			personal: .some(self.personal),
			sort: .none,
			withIssuesEnabled: .some(self.withIssuesEnabled),
			withMergeRequestsEnabled: .some(self.withMergeRequestsEnabled),
			archived: .some(.case(self.archived)),
			minAccessLevel: GraphFilter.toFilterEnum(self.accessLevel),
			aimedForDeletion: .some(self.aimedForDeletion),
			notAimedForDeletion: .some(self.notAimedForDeletion),
			markedForDeletionOn: GraphFilter.toFilterDate(self.markedForDeletionOn),
			active: GraphFilter.toFilter(self.active),
		)
	}

	public var body: some View {
		LoadableList(
			pager.state,
			hasMore: pager.hasMore,
			emptyMessage: "There are no projects",
			emptySystemImage: Icons.projects.rawValue,
			loadingMessage: "Loading Projects",
			loadingSystemImage: Icons.projects.rawValue,
			onLoadMore: { await pager.loadMore() },
			onRefresh: { await pager.refresh() }
		) { project in
			SmallProjectView(project)
		}.debouncedLoad(search) {
			await pager.start(query(), setCursor: { $0.after = .some($1) })
		}.toolbar {
			Button("Filter", systemImage: Icons.filter.rawValue) {
				showFilters = true
			}
		}.sheet(isPresented: $showFilters, onDismiss: { showFilters = false }) {
			NavigationStack {
				Form {
					Section {
						VStack(alignment: .leading) {
							Toggle("Membership", isOn: $membership)
							Text("Return only projects that the current user is a member of.")
								.foregroundStyle(.secondary)
								.font(.footnote)
						}
						VStack(alignment: .leading) {
							Toggle("Owner", isOn: $personal)
							Text("Return only personal projects.")
								.foregroundStyle(.secondary)
								.font(.footnote)
						}
					}
					Section {
						VStack(alignment: .leading) {
							Picker("Min. Access Level", selection: $accessLevel) {
								Text("None").tag(nil as AccessLevelEnum?)
								ForEach(AccessLevelEnum.allCases, id: \.self) { accessLevel in
									Text(accessLevel.rawValue.replacingOccurrences(of: "_", with: " ").capitalized).tag(
										accessLevel)
								}
							}
							Text("Return only projects where current user has at least the specified access level.")
								.foregroundStyle(.secondary)
								.font(.footnote)
						}
					}
					Section {
						VStack(alignment: .leading) {
							Picker("Active", selection: $active) {
								Text("Any").tag(nil as Bool?)
								Text("Only archived or marked for deletion").tag(false)
								Text("Only not archived and not marked for deletion").tag(true)
							}
							Text("Filters by projects that are not archived and not marked for deletion.")
								.foregroundStyle(.secondary)
								.font(.footnote)
						}
						VStack(alignment: .leading) {
							Picker("Archived", selection: $archived) {
								ForEach(ProjectArchived.allCases, id: \.self) { archived in
									Text(archived.rawValue.capitalized).tag(archived)
								}
							}
							Text("Filter projects by archived status.")
								.foregroundStyle(.secondary)
								.font(.footnote)
						}
						VStack(alignment: .leading) {
							Toggle("Aimed for Deletion", isOn: $aimedForDeletion)
							Text("Return only projects marked for deletion.")
								.foregroundStyle(.secondary)
								.font(.footnote)
						}
						VStack(alignment: .leading) {
							Toggle("Not aimed for Deletion", isOn: $notAimedForDeletion)
							Text("Exclude projects that are marked for deletion.")
								.foregroundStyle(.secondary)
								.font(.footnote)
						}
						VStack(alignment: .leading) {
							DatePicker(
								"Marked for Deletion on",
								selection: Binding(
									get: { self.markedForDeletionOn ?? SwiftUI.Date() },
									set: { self.markedForDeletionOn = $0 }
								),
								displayedComponents: .date
							)
							Text("Date when the project was marked for deletion.")
								.foregroundStyle(.secondary)
								.font(.footnote)
						}
					}
					Section {
						VStack(alignment: .leading) {
							Toggle("Issues enabled", isOn: $withIssuesEnabled)
							Text("Return only projects with issues enabled.")
								.foregroundStyle(.secondary)
								.font(.footnote)
						}
						VStack(alignment: .leading) {
							Toggle("MRs enabled", isOn: $withMergeRequestsEnabled)
							Text("Return only projects with merge requests enabled.")
								.foregroundStyle(.secondary)
								.font(.footnote)
						}
					}
				}.toolbar {
					AsyncButton("Apply filter", systemImage: "checkmark") {
						await pager.start(query(), setCursor: { $0.after = .some($1) })
						self.showFilters = false
					}
				}
				.navigationBarTitleDisplayMode(.inline)
				.navigationTitle("Projects Filter")
			}
		}.searchable(
			text: Binding(get: { self.search ?? "" }, set: { self.search = $0.isNotEmpty ? $0 : nil }),
			prompt: "Name, path, or description"
		).navigationTitle("Projects")
	}
}

#Preview {
	NavigationStack {
		ProjectsLoader()
	}
}
