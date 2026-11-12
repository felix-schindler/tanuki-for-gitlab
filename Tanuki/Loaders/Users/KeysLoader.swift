//
//  KeysLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 08.10.26.
//

import SwiftUI

struct KeysLoader: View {
	@State
	private var keys: Result<[RestAPISshKey], Error>? = nil

	@State private var showAdd = false
	@State private var keyToDelete: RestAPISshKey?

	private func loadKeys() async {
		do {
			let temp = try await API.get(type: [RestAPISshKey].self, endpoint: "user/keys")

			self.keys = .success(temp)
		} catch let error {
			self.keys = .failure(error)
			Notify.status(.error)
		}
	}

	private func deleteKey(_ key: RestAPISshKey) async {
		do {
			try await API.delete(endpoint: "user/keys/\(key.id)")

			if case .success(let keys) = keys {
				self.keys = .success(keys.filter { $0.id != key.id })
			}

			Notify.status(.success, "SSH key deleted", systemImage: "key")
		} catch let error {
			Notify.status(.error, "Couldn't delete SSH key", error.localizedDescription)
		}
	}

	public var body: some View {
		List {
			if let keys {
				switch keys {
				case .success(let keys):
					if keys.isEmpty {
						NoContentView(
							"You'll see your SSH keys after you added them",
							systemImage: "key"
						)
					} else {
						ForEach(keys, id: \.id) { key in
							DisclosureGroup(
								content: {
									Text(key.key)
										.font(.system(.footnote, design: .monospaced))
										.textSelection(.enabled)
								},
								label: {
									VStack(alignment: .leading) {
										Text(key.title)
											.font(.headline)
										ScrollView(.horizontal) {
											HStack {
												PillView(key.createdAt.toString(), icon: "calendar.badge.plus")
												if let lastUsedAt = key.lastUsedAt {
													PillView("Last used \(lastUsedAt.toString())")
												} else {
													PillView("Never used")
												}
												if let expiresAt = key.expiresAt {
													PillView(expiresAt.toString(), icon: "calendar.badge.clock")
												}
											}
										}.font(.footnote)
									}
								}
							)
							.swipeActions(edge: .trailing, allowsFullSwipe: true) {
								Button(role: .destructive) {
									keyToDelete = key
								} label: {
									Label("Delete", systemImage: "trash")
								}
							}
						}
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading SSH Keys", systemImage: "key")
			}
		}.task {
			await loadKeys()
		}.refreshable {
			await loadKeys()
		}.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button("Add", systemImage: "plus") {
					showAdd = true
				}
			}
		}.sheet(
			isPresented: $showAdd,
			onDismiss: {
				Task {
					await loadKeys()
				}
			}
		) {
			NavigationStack {
				NewSshKeyView()
			}
		}.confirmationDialog(
			"Delete \(keyToDelete?.title ?? "SSH key")?",
			isPresented: Binding(
				get: { keyToDelete != nil },
				set: { if !$0 { keyToDelete = nil } }
			),
			titleVisibility: .visible
		) {
			Button("Delete", role: .destructive) {
				if let key = keyToDelete {
					Task {
						await deleteKey(key)
					}
				}
				keyToDelete = nil
			}
			Button("Cancel", role: .cancel) {
				keyToDelete = nil
			}
		} message: {
			Text("This key will no longer be able to authenticate with this instance.")
		}.navigationTitle("SSH Keys")
	}
}

#Preview {
	NavigationStack {
		KeysLoader()
	}
}
