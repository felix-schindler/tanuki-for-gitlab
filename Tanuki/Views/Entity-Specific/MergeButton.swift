//
//  MergeButton.swift
//  Tanuki
//
//  Created by Felix Schindler on 14.10.25.
//

import GitLabAPI
import SwiftUI

struct MergeButton: View {
	private let iid: String
	private let projectId: Int
	private let onMerge: () async -> Void
	private let hasConflicts: Bool
	private let mergeStatusEnum: GraphQLEnum<GitLabAPI.MergeStatus>
	private let detailedMergeStatus: GraphQLEnum<GitLabAPI.DetailedMergeStatus>?

	// MARK: - Sheets
	@State private var showMergeStatus = false
	@State private var showMergeOptions = false

	// MARK: - Form
	@State private var autoMerge = false
	@State private var commitMessage = ""
	@State private var sha = ""
	@State private var removeSourceBranch = false
	@State private var squash = false
	@State private var squashMessage = ""

	init(
		iid: String,
		projectId: Int,
		onMerge: @escaping () async -> Void,
		hasConflicts: Bool,
		mergeStatusEnum: GraphQLEnum<GitLabAPI.MergeStatus>,
		detailedMergeStatus: GraphQLEnum<GitLabAPI.DetailedMergeStatus>?
	) {
		self.iid = iid
		self.projectId = projectId
		self.onMerge = onMerge
		self.hasConflicts = hasConflicts
		self.mergeStatusEnum = mergeStatusEnum
		self.detailedMergeStatus = detailedMergeStatus
	}

	private func merge() async {
		do {
			var body: [String: EncodableValue] = [:]

			if autoMerge {
				body["auto_merge"] = .boolean(true)
			}

			if commitMessage.isNotEmpty {
				body["merge_commit_message"] = .string(commitMessage)
			}

			if sha.isNotEmpty {
				body["sha"] = .string(sha)
			}

			if removeSourceBranch {
				body["should_remove_source_branch"] = .boolean(true)
			}

			if squash {
				body["squash"] = .boolean(true)

				if squashMessage.isNotEmpty {
					body["squash_commit_message"] = .string(squashMessage)
				}
			}

			_ = try await API.req(
				type: RestAPIMergeRequest.self,
				method: .put,
				endpoint: "projects/\(self.projectId)/merge_requests/\(self.iid)/merge",
				body: body
			)

			Notify.status(.success, "Merged request #\(self.iid)")
			await onMerge()
			showMergeOptions = false
		} catch let error {
			Notify.status(.error, "Failed to merge", error.localizedDescription)
		}
	}

	public var body: some View {
		Button {
			if mergeStatusEnum != .canBeMerged {
				showMergeStatus = true
			} else {
				showMergeOptions = true
			}
			Haptics.shared.play(.light)
		} label: {
			MergeStatus(mergeStatusEnum)
		}.sheet(isPresented: $showMergeStatus) {
			VStack(alignment: .leading) {
				PopupHeader(
					title: "Detailed merge status",
					onClose: {
						showMergeStatus = false
					}
				)

				if hasConflicts {
					Label(
						title: {
							Text("Merge conflicts must be resolved.")
						},
						icon: {
							Image(systemName: "minus.circle.fill")
								.foregroundStyle(.red)
						}
					)
				}

				if let detailedMergeStatus {
					DetailedMergeStatusView(detailedMergeStatus)
				}

				Spacer()
			}
			.padding()
			.presentationDetents([.fraction(0.2), .medium])
		}.sheet(isPresented: $showMergeOptions) {
			NavigationStack {
				Form {
					Toggle("Merge when the pipeline succeeds", isOn: $autoMerge)
					TextField("Custom merge commit message", text: $commitMessage)
					VStack(alignment: .leading) {
						TextField("SHA", text: $sha)
						Text(
							"If present, then this SHA must match the HEAD of the source branch, otherwise the merge fails."
						)
						.foregroundStyle(.secondary)
						.font(.footnote)
					}
					Toggle("Remove source branch", isOn: $removeSourceBranch)
					Toggle("Squash all commits into a single commit on merge", isOn: $squash)
					if squash {
						TextField("Custom squash commit message", text: $squashMessage)
					}
				}.toolbar {
					ToolbarItem(placement: .topBarLeading) {
						Button("Cancel", systemImage: "xmark", role: .cancel) {
							showMergeOptions = false
						}
					}
					ToolbarItem(placement: .topBarTrailing) {
						AsyncButton("Merge", systemImage: "checkmark") {
							await merge()
						}.labelStyle(.titleAndIcon)
					}
				}
				.navigationBarTitleDisplayMode(.inline)
				.navigationTitle("Merge options")
			}
		}
	}
}

#Preview {
	MergeButton(
		iid: "0",
		projectId: 0,
		onMerge: {
			print("MERGE")
		},
		hasConflicts: false,
		mergeStatusEnum: .case(.canBeMerged),
		detailedMergeStatus: nil
	)
}
