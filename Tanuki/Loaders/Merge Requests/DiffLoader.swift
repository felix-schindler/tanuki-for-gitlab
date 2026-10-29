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
	private var diffs: Result<[Diff], Error>? = nil

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

	private func loadDiffs() async {
		do {
			if let iid = self.mrIid {
				let diffs = try await API.get(
					type: [Diff].self,
					endpoint: "projects/\(self.projectId)/merge_requests/\(iid)/diffs",
					query: [
						"unidiff": String(self.unidiff)
					]
				)

				self.diffs = .success(diffs)
			} else if let sha = self.commitSha {
				let diffs = try await API.get(
					type: [Diff].self,
					endpoint: "projects/\(self.projectId)/repository/commits/\(sha)/diff",
					query: [
						"unidiff": String(self.unidiff)
					]
				)

				self.diffs = .success(diffs)
			}
		} catch let error {
			self.diffs = .failure(error)
			Notify.status(.error)
		}
	}

	var body: some View {
		List {
			Section {
				Toggle("Unified diff", isOn: $unidiff)
					.onChange(of: unidiff) {
						Task {
							await loadDiffs()
							Haptics.shared.play(.soft)
						}
					}
			}

			if let diffs {
				switch diffs {
				case .success(let diffs):
					if diffs.isEmpty {
						NoContentView("There are no changes", lucide: .diff)
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
											LucideLabelIcon(.squarePlus, color: .green)
										} else if diff.renamedFile {
											LucideLabelIcon(.squareArrowRight, color: .blue)
										} else if diff.deletedFile {
											LucideLabelIcon(.squareMinus, color: .red)
										} else if diff.generatedFile ?? false {
											LucideLabelIcon(.cog, color: .purple)
										} else {
											LucideLabelIcon(.squarePen, color: .orange)
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
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading Diffs", lucide: .diff)
			}
		}.task {
			await loadDiffs()
		}.refreshable {
			await loadDiffs()
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
