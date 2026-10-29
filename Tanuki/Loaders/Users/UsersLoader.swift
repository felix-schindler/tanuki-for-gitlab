//
//  UsersLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 12.10.25.
//

import GitLabAPI
import SwiftUI

struct UsersLoader: View {
	@State
	private var users: Result<[Author?], Error>? = nil

	@State
	private var showFilters = false

	@State
	private var loadTask: Task<Void, Never>?

	// MARK: - Filters
	@State public private(set) var search: String? = nil
	@State public private(set) var admins = false
	@State public private(set) var active: Bool? = nil
	@State public private(set) var humans: Bool? = nil

	// MARK: - Data loading
	private var query: UsersQuery {
		return UsersQuery(
			search: GraphFilter.toFilter(self.search),
			admins: .some(self.admins),
			active: GraphFilter.toFilter(self.active),
			humans: GraphFilter.toFilter(self.humans)
		)
	}

	private func loadUsers() {
		self.loadTask?.cancel()
		self.loadTask = Task {
			do {
				let responses = try Network.shared.apollo.fetch(
					query: self.query,
					cachePolicy: .cacheAndNetwork
				)

				for try await response in responses {
					if Task.isCancelled { return }
					if let users = response.data?.users?.nodes {
						self.users = .success(users)
					} else if let errors = response.errors {
						for error in errors {
							Notify.status(.error, error.localizedDescription)
						}
					}
				}
			} catch {
				if !Task.isCancelled {
					self.users = .failure(error)
					Notify.status(.error)
				}
			}
		}
	}

	private func reloadUsers() async {
		do {
			let response = try await Network.shared.apollo.fetch(
				query: self.query,
				cachePolicy: .networkOnly
			)

			if let users = response.data?.users?.nodes {
				self.users = .success(users)
			}

			Notify.status(.success)
		} catch let error {
			self.users = .failure(error)
			Notify.status(.error)
		}
	}

	public var body: some View {
		List {
			if let users {
				switch users {
				case .success(let users):
					if users.isEmpty {
						NoContentView("There are no users", lucide: .users)
					} else {
						ForEach(users, id: \.self?.username) { user in
							if let user {
								AuthorView(user)
							}
						}
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading Users", lucide: .users)
			}
		}.task {
			loadUsers()
		}.refreshable {
			await reloadUsers()
		}.toolbar {
			Button("Filter", lucide: .listFilter) {
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
					AsyncButton("Apply filter", lucide: .check) {
						await reloadUsers()
						self.showFilters = false
					}
				}
				.navigationBarTitleDisplayMode(.inline)
				.navigationTitle("Users Filter")
			}
		}.searchable(
			text: Binding(get: { self.search ?? "" }, set: { self.search = $0.isNotEmpty ? $0 : nil }),
			prompt: "Name, username, or primary email"
		).onChange(of: search) {
			self.users = nil  // Show loading state
			loadUsers()
		}.navigationTitle("Users")
	}
}

#Preview {
	UsersLoader()
}
