//
//  DiffLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 07.04.24.
//

import SwiftUI

struct Diff: Codable {
	/// Old path of the file.
	let oldPath: String
	/// New path of the file.
	let newPath: String
	///Old file mode of the file.
	let aMode: String?
	///New file mode of the file.
	let bMode: String?
	/// Diff representation of the changes made to the file.
	let diff: String
	/// Indicates if the file has just been added.
	let newFile: Bool
	/// Indicates if the file has been renamed.
	let renamedFile: Bool
	/// Indicates if the file has been removed.
	let deletedFile: Bool
	/// Indicates if the file is marked as generated. Introduced in GitLab 16.9.
	var generatedFile: Bool?
}

struct DiffLoader: View {
	private let projectId: Int
	private let mrIid: Int?
	private let commitSha: String?

	@Environment(\.colorScheme)
	private var colorScheme: ColorScheme

	@State
	private var state = Loadable<[Diff]>()

	@State
	private var pager = RestPage()

	@AppStorage("diff_unified")
	private var unidiff = false

	init(projectId: Int, mrIid: Int? = nil, commitSha: String? = nil) {
		self.projectId = projectId
		self.mrIid = mrIid
		self.commitSha = commitSha

		if mrIid == nil && commitSha == nil {
			fatalError("Either IID or SHA needs to be provided")
		}
	}

	private var endpoint: String {
		if let iid = mrIid {
			return "projects/\(projectId)/merge_requests/\(iid)/diffs"
		}
		return "projects/\(projectId)/repository/commits/\(commitSha ?? "")/diff"
	}

	private var query: [String: String] {
		var query = pager.query
		query["unidiff"] = String(unidiff)
		return query
	}

	private func load(reset: Bool) async {
		if reset {
			pager.reset()
			state.isLoading = true
		} else {
			state.isLoadingMore = true
		}

		defer {
			state.isLoading = false
			state.isLoadingMore = false
		}

		do {
			let diffs = try await API.get(
				type: [Diff].self, endpoint: endpoint, query: query)

			if Task.isCancelled { return }
			if reset {
				state.value = diffs
			} else {
				// Cursor-less REST pages can overlap after a force push; drop repeats.
				let known = Set((state.value ?? []).map { $0.oldPath + "\0" + $0.newPath })
				state.value =
					(state.value ?? [])
					+ diffs.filter { !known.contains($0.oldPath + "\0" + $0.newPath) }
			}
			state.error = nil
			pager.advance(diffs.count)
		} catch {
			if Task.isCancelled { return }
			state.error = error
			Notify.status(.error)
		}
	}

	private func loadMore() async {
		guard pager.hasMore, !state.isLoading, !state.isLoadingMore else { return }
		await load(reset: false)
	}

	var body: some View {
		List {
			Section {
				Toggle("Unified diff", isOn: $unidiff)
					.onChange(of: unidiff) {
						Haptics.shared.play(.soft)
					}
			}

			if state.isInitialLoading {
				LoadingView("Loading Diffs", systemImage: Icons.diffStats.rawValue)
			} else if state.isColdFailure, let error = state.error {
				FailedView(error)
			} else if let diffs = state.value {
				if diffs.isEmpty {
					NoContentView("There are no changes", systemImage: Icons.diffStats.rawValue)
				} else {
					ForEach(diffs, id: \.oldPath) { diff in
						Section(
							content: {
								VStack(alignment: .leading) {
									if diff.aMode != diff.bMode {
										Text(
											"Mode changed: \(diff.aMode ?? "null") → \(diff.bMode ?? "null")"
										)
										.padding(.bottom)
									}
									CodeTextView(
										diff.diff,
										language: "diff",
										colorScheme: self.colorScheme,
										fontSize: 12
									)
								}
							},
							header: {
								HStack {
									if diff.newFile {
										Image(systemName: "plus.square")
											.foregroundStyle(.green)
									} else if diff.renamedFile {
										Image(systemName: "arrow.right.square")
											.foregroundStyle(.blue)
									} else if diff.deletedFile {
										Image(systemName: "minus.square")
											.foregroundStyle(.red)
									} else if diff.generatedFile ?? false {
										Image(systemName: "gear.circle")
											.foregroundStyle(.purple)
									} else {
										Image(systemName: "dot.square")
											.foregroundStyle(.orange)
									}

									ScrollView(.horizontal) {
										if diff.renamedFile {
											Text("\(diff.oldPath) → \(diff.newPath)")
										} else {
											Text(diff.newPath)
										}
									}
								}
							})
					}

					if pager.hasMore {
						HStack {
							Spacer()
							ProgressView()
							Spacer()
						}.task {
							await loadMore()
						}
					}
				}
			}
		}.task(id: unidiff) {
			await load(reset: true)
		}.refreshable {
			await load(reset: true)
		}
		.listStyle(.grouped)
		.headerProminence(.increased)
		.navigationTitle("Diffs")
	}
}

#Preview {
	NavigationStack {
		DiffLoader(
			projectId: 33_025_310,
			mrIid: 1
		)
	}
}
