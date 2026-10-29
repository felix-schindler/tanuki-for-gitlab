//
//  ProjectsLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 11.10.25.
//

import GitLabAPI
import SwiftUI

struct ProjectsLoader: View {
	@State
	private var projects: Result<[SmallProject?], Error>? = nil

	@State
	private var showFilters = false

	@State
	private var loadTask: Task<Void, Never>?

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

	private var query: ProjectsQuery {
		return ProjectsQuery(
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

	// MARK: - Data loading
	private func loadProjects() {
		self.loadTask?.cancel()
		self.loadTask = Task {
			do {
				let responses = try Network.shared.apollo.fetch(
					query: self.query,
					cachePolicy: .cacheAndNetwork
				)

				for try await response in responses {
					if Task.isCancelled { return }
					if let projects = response.data?.projects?.nodes {
						self.projects = .success(projects)
					} else if let errors = response.errors {
						for error in errors {
							Notify.status(.error, error.localizedDescription)
						}
					}
				}
			} catch {
				if !Task.isCancelled {
					self.projects = .failure(error)
					Notify.status(.error)
				}
			}
		}
	}

	private func reloadProjects() async {
		do {
			let response = try await Network.shared.apollo.fetch(
				query: self.query,
				cachePolicy: .networkOnly
			)

			if let projects = response.data?.projects?.nodes {
				self.projects = .success(projects)
			}

			Notify.status(.success)
		} catch let error {
			self.projects = .failure(error)
			Notify.status(.error)
		}
	}

	public var body: some View {
		List {
			if let projects {
				switch projects {
				case .success(let projects):
					if projects.isEmpty {
						NoContentView("There are no projects", lucide: .layers)
					} else {
						ForEach(projects, id: \.?.fullPath) { project in
							if let project {
								SmallProjectView(project)
							}
						}
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading Projects", lucide: .layers)
			}
		}.task {
			loadProjects()
		}.refreshable {
			await reloadProjects()
		}.toolbar {
			Button("Filter", lucide: .listFilter) {
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
									Text(accessLevel.rawValue.replacing("_", with: " ").capitalized).tag(accessLevel)
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
					AsyncButton("Apply filter", lucide: .check) {
						await reloadProjects()
						self.showFilters = false
					}
				}
				.navigationBarTitleDisplayMode(.inline)
				.navigationTitle("Projects Filter")
			}
		}.searchable(
			text: Binding(get: { self.search ?? "" }, set: { self.search = $0.isNotEmpty ? $0 : nil }),
			prompt: "Name, path, or description"
		).onChange(of: search) {
			self.projects = nil  // Show loading state
			loadProjects()
		}.navigationTitle("Projects")
	}
}

#Preview {
	NavigationStack {
		ProjectsLoader()
	}
}
