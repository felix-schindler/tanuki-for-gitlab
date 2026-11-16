//
//  GroupsLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 12.10.25.
//

import GitLabAPI
import SwiftUI

struct GroupsLoader: View {
	@State
	private var pager = PagedQuery<GroupsQuery, Group>(
		extract: { ($0.groups?.nodes ?? []).compactMap { $0 } },
		key: { $0.fullPath },
		hasNext: { $0.groups?.pageInfo.hasNextPage ?? false },
		endCursor: { $0.groups?.pageInfo.endCursor }
	)

	@State
	private var showFilters = false

	@State
	private var createGroup = false

	// MARK: - Filter
	public private(set) var parentPath: String? = nil
	@State public private(set) var search: String? = nil
	@State public private(set) var topLevelOnly: Bool = false
	@State public private(set) var ownedOnly: Bool = false
	@State public private(set) var allAvailable: Bool = true
	@State public private(set) var markedForDeletionOn: SwiftUI.Date? = nil
	@State public private(set) var active: Bool? = nil

	private func query(after: GraphQLNullable<String> = .none) -> GroupsQuery {
		return GroupsQuery(
			first: 50,
			after: after,
			topLevelOnly: .some(self.topLevelOnly),
			ownedOnly: .some(self.ownedOnly),
			search: GraphFilter.toFilter(self.search),
			parentPath: GraphFilter.toFilter(self.parentPath),
			allAvailable: GraphFilter.toFilter(allAvailable),
			markedForDeletionOn: GraphFilter.toFilterDate(self.markedForDeletionOn),
			active: GraphFilter.toFilter(self.active)
		)
	}

	public var body: some View {
		LoadableList(
			pager.state,
			hasMore: pager.hasMore,
			emptyMessage: "There are no groups",
			emptySystemImage: Icons.groups.rawValue,
			loadingMessage: "Loading Groups",
			loadingSystemImage: Icons.groups.rawValue,
			onLoadMore: { await pager.loadMore() },
			onRefresh: { await pager.refresh() }
		) { group in
			SmallGroupView(group: group)
		}.debouncedLoad(search) {
			await pager.start(query(), setCursor: { $0.after = .some($1) })
		}.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button("Filter", systemImage: Icons.filter.rawValue) {
					showFilters = true
				}
			}
			ToolbarItem(placement: .topBarTrailing) {
				Button("New group", systemImage: "plus") {
					createGroup = true
				}
			}
		}.navigationDestination(isPresented: $createGroup) {
			NewGroupView()
		}.sheet(isPresented: $showFilters, onDismiss: { showFilters = false }) {
			NavigationStack {
				Form {
					Section {
						VStack(alignment: .leading) {
							Toggle(
								"Membership",
								isOn: Binding<Bool>(
									get: { !self.allAvailable },
									set: { self.allAvailable = !$0 }
								)
							)
							Text("Only return groups where you are a member")
								.foregroundStyle(.secondary)
								.font(.footnote)
						}
						VStack(alignment: .leading) {
							Toggle("Owner", isOn: $ownedOnly)
							Text("Only include groups where the current user has an owner role.")
								.foregroundStyle(.secondary)
								.font(.footnote)
						}
					}
					Section {
						VStack(alignment: .leading) {
							Picker("Active", selection: $active) {
								Text("Any").tag(nil as Bool?)
								Text("Only not pending deletion").tag(true)
								Text("Only pending deletion").tag(false)
							}
							Text("Filters by projects that are not archived and not marked for deletion.")
								.foregroundStyle(.secondary)
								.font(.footnote)
						}
						VStack(alignment: .leading) {
							Toggle("Top Level Only", isOn: $topLevelOnly)
							Text("Only include top-level groups.")
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
							Text("Date when the group was marked for deletion.")
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
				.navigationTitle("Groups Filter")
			}
		}.searchable(
			text: Binding(get: { self.search ?? "" }, set: { self.search = $0.isNotEmpty ? $0 : nil }),
			prompt: "Name or full path"
		).navigationTitle("Groups")
	}
}

#Preview {
	NavigationStack {
		GroupsLoader()
	}
}
