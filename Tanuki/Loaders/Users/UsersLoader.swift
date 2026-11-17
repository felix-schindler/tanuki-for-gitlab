//
//  UsersLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 12.10.25.
//

import GitLabAPI
import SwiftUI
import TanukiShared

struct UsersLoader: View {
	@State
	private var pager = PagedQuery<UsersQuery, Author>(
		extract: { ($0.users?.nodes ?? []).compactMap { $0 } },
		key: { $0.username },
		hasNext: { $0.users?.pageInfo.hasNextPage ?? false },
		endCursor: { $0.users?.pageInfo.endCursor }
	)

	@State
	private var showFilters = false

	// MARK: - Filters
	@State public private(set) var search: String? = nil
	@State public private(set) var admins = false
	@State public private(set) var active: Bool? = nil
	@State public private(set) var humans: Bool? = nil

	// MARK: - Data loading
	private func query(after: GraphQLNullable<String> = .none) -> UsersQuery {
		return UsersQuery(
			first: 50,
			after: after,
			search: GraphFilter.toFilter(self.search),
			admins: .some(self.admins),
			active: GraphFilter.toFilter(self.active),
			humans: GraphFilter.toFilter(self.humans)
		)
	}

	public var body: some View {
		LoadableList(
			pager.state,
			hasMore: pager.hasMore,
			emptyMessage: "There are no users",
			emptySystemImage: Icons.members.rawValue,
			loadingMessage: "Loading Users",
			loadingSystemImage: Icons.members.rawValue,
			onLoadMore: { await pager.loadMore() },
			onRefresh: { await pager.refresh() }
		) { user in
			AuthorView(user)
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
							Toggle("Admins", isOn: $admins)
							Text("Return only admin users.")
								.foregroundStyle(.secondary)
								.font(.footnote)
						}
						Picker("Active", selection: $active) {
							Text("Any").tag(nil as Bool?)
							Text("Only active").tag(true)
							Text("Only non-active").tag(false)
						}
						Picker("Humans", selection: $humans) {
							Text("Any").tag(nil as Bool?)
							Text("Only not bot or internal users").tag(true)
							Text("Only bot or internal users").tag(false)
						}
					}
				}.toolbar {
					AsyncButton("Apply filter", systemImage: "checkmark") {
						await pager.start(query(), setCursor: { $0.after = .some($1) })
						self.showFilters = false
					}
				}
				.navigationBarTitleDisplayMode(.inline)
				.navigationTitle("Users Filter")
			}
		}.searchable(
			text: Binding(get: { self.search ?? "" }, set: { self.search = $0.isNotEmpty ? $0 : nil }),
			prompt: "Name, username, or primary email"
		).navigationTitle("Users")
	}
}

#Preview {
	UsersLoader()
}
