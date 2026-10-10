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
	private var groups: Result<[Group?], Error>? = nil

	@State
	private var showFilters = false

	@State
	private var loadTask: Task<Void, Never>?

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

	private var query: GroupsQuery {
		return GroupsQuery(
			topLevelOnly: .some(self.topLevelOnly),
			ownedOnly: .some(self.ownedOnly),
			search: GraphFilter.toFilter(self.search),
			parentPath: GraphFilter.toFilter(self.parentPath),
			allAvailable: GraphFilter.toFilter(allAvailable),
			markedForDeletionOn: GraphFilter.toFilterDate(self.markedForDeletionOn),
			active: GraphFilter.toFilter(self.active)
		)
	}

	// MARK: - Data loading
	private func loadGroups() {
		self.loadTask?.cancel()
		self.loadTask = Task {
			do {
				let responses = try Network.shared.apollo.fetch(
					query: self.query,
					cachePolicy: .cacheAndNetwork
				)

				for try await response in responses {
					if Task.isCancelled { return }
					if let groups = response.data?.groups?.nodes {
						self.groups = .success(groups)
					} else if let errors = response.errors {
						for error in errors {
							Notify.status(.error, error.localizedDescription)
						}
					}
				}
			} catch {
				if !Task.isCancelled {
					self.groups = .failure(error)
					Notify.status(.error)
				}
			}
		}
	}

	private func reloadGroups() async {
		do {
			let response = try await Network.shared.apollo.fetch(
				query: self.query,
				cachePolicy: .networkOnly
			)

			if let groups = response.data?.groups?.nodes {
				self.groups = .success(groups)
			}

			Notify.status(.success)
		} catch let error {
			self.groups = .failure(error)
			Notify.status(.error)
		}
	}

	public var body: some View {
		List {
			if let groups {
				switch groups {
				case .success(let groups):
					if groups.isEmpty {
						NoContentView("There are no groups", lucide: .building)
					} else {
						ForEach(groups, id: \.self?.fullPath) { group in
							if let group {
								SmallGroupView(group: group)
							}
						}
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading Groups", lucide: .building)
			}
		}.task {
			loadGroups()
		}.refreshable {
			await reloadGroups()
		}.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button("Filter", lucide: .listFilter) {
					showFilters = true
				}
			}
			ToolbarItem(placement: .topBarTrailing) {
				Button("New group", lucide: .plus) {
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
					AsyncButton("Apply filter", lucide: .check) {
						await reloadGroups()
						self.showFilters = false
					}
				}
				.navigationBarTitleDisplayMode(.inline)
				.navigationTitle("Groups Filter")
			}
		}.searchable(
			text: Binding(get: { self.search ?? "" }, set: { self.search = $0.isNotEmpty ? $0 : nil }),
			prompt: "Name or full path"
		).onChange(of: search) {
			self.groups = nil  // Show loading state
			loadGroups()
		}.navigationTitle("Groups")
	}
}

#Preview {
	NavigationStack {
		GroupsLoader()
	}
}
