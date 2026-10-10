//
//  MergeRequest.swift
//  Tanuki
//
//  Created by Felix Schindler on 27.02.24.
//

import GitLabAPI
import SwiftUI

struct MergeRequestLoader: View {
	@Environment(\.dismiss) private var dismiss

	private let fullPath: String
	private let iid: String

	@State
	private var project: Result<GitLabAPI.MergeRequestQuery.Data.Project, Error>? = nil

	init(fullPath: String, iid: String) {
		self.fullPath = fullPath
		self.iid = iid
	}

	private func handleGraphQLErrors(_ errors: [any Error]?) {
		guard let errors, !errors.isEmpty else { return }

		let messages = errors.map(\.localizedDescription)
		Notify.status(
			.error, "Couldn't load merge request !\(iid)", messages.first,
			systemImage: "exclamationmark.triangle")

		if project == nil {
			self.project = .failure(
				ProjectLoadError(fullPath: "\(fullPath) !\(iid)", messages: messages))
		}
	}

	private func loadMergeRequest() {
		do {
			let responses = try Network.shared.apollo.fetch(
				query: MergeRequestQuery(fullPath: self.fullPath, iid: self.iid),
				cachePolicy: .cacheAndNetwork
			)

			Task {
				for try await response in responses {
					if let project = response.data?.project {
						self.project = .success(project)
					}
					self.handleGraphQLErrors(response.errors)
				}
			}
		} catch let error {
			self.project = .failure(error)
			Notify.status(.error, "Couldn't load merge request !\(iid)", error.localizedDescription)
		}
	}

	private func reloadMergeRequest() async {
		do {
			let response = try await Network.shared.apollo.fetch(
				query: MergeRequestQuery(fullPath: self.fullPath, iid: self.iid),
				cachePolicy: .networkOnly
			)

			if let project = response.data?.project {
				self.project = .success(project)
				Notify.status(.success)
			} else {
				handleGraphQLErrors(response.errors)
				if response.errors?.isEmpty ?? true {
					self.project = .failure(
						ProjectLoadError(
							fullPath: "\(fullPath) !\(iid)",
							messages: ["GitLab returned no merge request."]))
				}
			}
		} catch let error {
			self.project = .failure(error)
			Notify.status(.error, "Couldn't load merge request !\(iid)", error.localizedDescription)
		}
	}

	private func approve(_ projectId: Int) async {
		do {
			_ = try await API.req(
				type: RestAPIMergeRequest.self, method: .post,
				endpoint: "projects/\(projectId)/merge_requests/\(self.iid)/approve")
			await reloadMergeRequest()
		} catch let error {
			Notify.status(.error, "Failed to approve", error.localizedDescription)
		}
	}

	private func unapprove(_ projectId: Int) async {
		do {
			_ = try await API.req(
				type: RestAPIMergeRequest.self, method: .post,
				endpoint: "projects/\(projectId)/merge_requests/\(self.iid)/unapprove")
			await reloadMergeRequest()
		} catch let error {
			Notify.status(.error, "Failed to unapprove", error.localizedDescription)
		}
	}

	private func changeState(_ projectId: Int, state: String) async {
		var body: [String: EncodableValue] = [:]
		body["state_event"] = .string(state)

		do {
			_ = try await API.req(
				type: RestAPIMergeRequest.self,
				method: .put,
				endpoint: "projects/\(projectId)/merge_requests/\(self.iid)",
				body: body
			)
			await reloadMergeRequest()
		} catch let error {
			Notify.status(.error, "Failed to change state", error.localizedDescription)
		}
	}

	private static let draftPrefixes = ["draft: ", "[draft] ", "(draft) "]

	private static func isDraft(_ title: String) -> Bool {
		let lower = title.lowercased()
		return draftPrefixes.contains { lower.hasPrefix($0) }
	}

	private static func readyTitle(_ title: String) -> String {
		var result = title
		while let prefix = draftPrefixes.first(where: { result.lowercased().hasPrefix($0) }) {
			result = String(result.dropFirst(prefix.count)).trimmingCharacters(in: .whitespaces)
		}
		return result
	}

	// GitLab derives draft status from the title prefix, so toggling it is the
	// same PUT-title pattern as close/reopen — no schema change needed.
	private func changeDraft(_ projectId: Int, title: String, toDraft: Bool) async {
		let body: [String: EncodableValue] = [
			"title": .string(toDraft ? "Draft: \(title)" : Self.readyTitle(title))
		]

		do {
			_ = try await API.req(
				type: RestAPIMergeRequest.self,
				method: .put,
				endpoint: "projects/\(projectId)/merge_requests/\(self.iid)",
				body: body
			)
			await reloadMergeRequest()
		} catch let error {
			Notify.status(.error, "Failed to change draft state", error.localizedDescription)
		}
	}

	private func remove(_ projectId: Int) async {
		do {
			_ = try await API.delete(endpoint: "projects/\(projectId)/merge_requests/\(self.iid)")
			dismiss()
		} catch let error {
			Notify.status(.error, "Failed to delete MR", error.localizedDescription)
		}
	}

	public var body: some View {
		List {
			if let project {
				switch project {
				case .success(let project):
					if let mr = project.mergeRequest {
						VStack(alignment: .leading) {
							HStack(spacing: 5) {
								if let url = URL.fromAvatar(project.avatarUrl) {
									AvatarImage(url, size: .tiny)
								}
								ScrollView(.horizontal) {
									Text(mr.reference)
										.foregroundStyle(.secondary)
								}
								Spacer()
								Text(Date.fromToString(mr.createdAt))
							}
							.font(.footnote)
							.padding(.bottom, 1)

							Text(mr.title.emojized())
								.font(.title3)
								.fontWeight(.medium)
								.padding(.bottom, 1)

							ScrollView(.horizontal) {
								HStack(spacing: 5) {
									if let author = mr._author {
										ScrollView(.horizontal) {
											AuthorView(author)
										}
									}

									if let sourceProject = mr.sourceProject,
										sourceProject.fullPath != self.fullPath
									{
										NavigationLink(
											destination: ProjectLoader(
												fullPath: sourceProject.fullPath
											),
											label: {
												PillView(
													"\(sourceProject.fullPath)/\(mr.sourceBranch)",
													bgColor: .blue,
													fgColor: .white,
													cornerRadius: 5
												)
												.font(.system(.footnote, design: .monospaced))
												.textSelection(.enabled)
											}
										)
									} else {
										PillView(
											mr.sourceBranch,
											bgColor: .blue,
											fgColor: .white,
											cornerRadius: 5
										)
										.font(.system(.footnote, design: .monospaced))
										.textSelection(.enabled)
									}

									LucideLabelIcon(.arrowRight)

									PillView(
										mr.targetBranch,
										bgColor: .blue,
										fgColor: .white,
										cornerRadius: 5
									)
									.font(.system(.footnote, design: .monospaced))
									.textSelection(.enabled)
								}
							}.font(.footnote)

							if let description = mr.description, description.isNotEmpty {
								Markdown(description)
							}

							HStack {
								VotePillsView(
									projectId: project.id.toIntId(),
									iid: self.iid,
									type: .mergeRequest,
									upvotes: mr.upvotes,
									downvotes: mr.downvotes
								) {
									await reloadMergeRequest()
								}
							}
							.modifier(LabelSpacingIfAvailable())
							.font(.footnote)
						}

						Section("Details") {
							let assgineeCount = mr.assignees?.nodes?.count ?? 0
							DisclosureGroup(
								content: {
									if assgineeCount > 0 {
										ForEach(mr.assignees!.nodes!, id: \.self) {
											maybeUser in
											if let user = maybeUser {
												NavigationLink(
													destination: UserLoader(
														username: user.username),
													label: {
														HStack {
															if let url =
																URL.fromAvatar(
																	user.avatarUrl)
															{
																AvatarImage(
																	url,
																	size: .small)
															}
															Text(user.username)
														}
													}
												)
											}
										}
									} else {
										Text("There are no assignees")
									}
								},
								label: {
									Label(
										title: {
											HStack {
												Text("Assignees")
												Spacer()
												Text("\(assgineeCount)")
											}
										},
										icon: {
											LucideLabelIcon(.circleUserRound)
										})
								}
							)

							let reviewerCount = mr.reviewers?.nodes?.count ?? 0
							DisclosureGroup(
								content: {
									if reviewerCount > 0 {
										ForEach(mr.reviewers!.nodes!, id: \.self) {
											maybeUser in
											if let user = maybeUser {
												NavigationLink(
													destination: UserLoader(
														username: user.username),
													label: {
														HStack {
															if let url = URL.fromAvatar(user.avatarUrl) {
																AvatarImage(url, size: .small)
															}
															Text(user.username)
														}
													}
												)
											}
										}
									} else {
										Text("There are no reviewers")
									}
								},
								label: {
									Label(
										title: {
											HStack {
												Text("Reviewers")
												Spacer()
												Text("\(reviewerCount)")
											}
										},
										icon: {
											LucideLabelIcon(.users)
										})
								}
							)

							if let labels = mr.labels?.nodes, labels.isNotEmpty {
								Label(
									title: {
										ScrollView(.horizontal) {
											HStack {
												ForEach(labels, id: \.?.title) { label in
													if let label {
														PillView(
															label.title,
															bgColor: Color(hex: label.color),
															fgColor: Color(hex: label.textColor)
														)
													}
												}
											}
										}
									},
									icon: {
										LucideLabelIcon(.tag)
									}
								)
							}

							if let milestone = mr.milestone {
								Label(
									milestone.title,
									lucide: .milestone
								)
							}

							if mr.humanTimeEstimate != nil
								|| mr.humanTotalTimeSpent != nil
							{
								Label(
									title: {
										HStack {
											Text("Estimate: \(mr.humanTimeEstimate ?? "none")")
											Spacer()
											Text("Spent: \(mr.humanTotalTimeSpent ?? "none")")
										}
									},
									icon: {
										LucideLabelIcon(.hourglass)
									}
								)
							}
						}

						Section("Changes") {
							let projectId = project.id.toIntId()
							let iid = self.iid.toIntId()
							NavigationLink(
								destination: DiffLoader(
									projectId: projectId ?? 0,
									mrIid: iid ?? 0
								),
								label: {
									if let diffStats = mr.diffStatsSummary {
										Label(
											title: {
												HStack {
													Text("\(diffStats.fileCount) files changed")
													Spacer()
													HStack {
														Text("+\(diffStats.additions)")
															.foregroundStyle(.green)
														Text("-\(diffStats.deletions)")
															.foregroundStyle(.red)
													}.font(.system(.body, design: .monospaced))
												}
											},
											icon: {
												LucideLabelIcon(.fileText)
											}
										)
									} else {
										Text("Diff")
									}
								}
							).disabled(projectId == nil || iid == 0)

							NavigationLink(
								destination: DiffsStatsLoader(
									fullPath: self.fullPath,
									iid: self.iid
								),
								label: {
									Label("Changed files overview", lucide: .diff)
								}
							)

							NavigationLink(
								destination: MrCommitsLoader(
									fullPath: self.fullPath,
									iid: self.iid
								),
								label: {
									Label("Commits", lucide: .gitCommitHorizontal)
								}
							)
						}

						let showMergeSection =
							(mr.userPermissions.canApprove
								|| mr.userPermissions.canMerge
								|| mr.userPermissions.updateMergeRequest)
						if showMergeSection,
							let projectId = project.id.toIntId()
						{
							Section("Actions") {
								if mr.userPermissions.canMerge {
									MergeButton(
										iid: mr.iid,
										projectId: projectId,
										onMerge: {
											await reloadMergeRequest()
										},
										hasConflicts: mr.conflicts,
										mergeStatusEnum: mr.mergeStatusEnum ?? .case(.canBeMerged),
										detailedMergeStatus: mr.detailedMergeStatus
									)
								}

								if mr.userPermissions.canApprove {
									AsyncButton(
										"Approve",
										lucide: .userCheck
									) {
										await approve(projectId)
									}.tint(.green)
								} else if mr.approved {
									AsyncButton(
										"Revoke approval",
										lucide: .userX
									) {
										await unapprove(projectId)
									}.tint(.red)
								}

								if mr.userPermissions.updateMergeRequest {
									NavigationLink(
										destination: EditTitleDescriptionView(
											projectId: projectId,
											iid: self.iid,
											type: .mergeRequest,
											initialTitle: mr.title,
											initialDescription: mr.description ?? ""
										) {
											await reloadMergeRequest()
										}
									) {
										Label("Edit MR", lucide: .pencil)
									}

									if mr.state == .opened {
										AsyncButton(
											Self.isDraft(mr.title) ? "Mark as ready" : "Mark as draft",
											lucide: Self.isDraft(mr.title) ? .flagOff : .flag
										) {
											await changeDraft(
												projectId, title: mr.title,
												toDraft: !Self.isDraft(mr.title))
										}.tint(Self.isDraft(mr.title) ? .green : .orange)

										AsyncButton("Close MR", lucide: .gitPullRequestClosed) {
											await changeState(projectId, state: "close")
										}.tint(.blue)
									} else if mr.state == .closed {
										AsyncButton("Reopen MR", lucide: .gitPullRequest) {
											await changeState(projectId, state: "reopen")
										}.tint(.green)
									}

									AsyncButton("Delete MR", lucide: .trash) {
										await remove(projectId)
									}.tint(.red)
								}
							}
						}

						let noteCount = mr.notes.nodes?.count ?? 0
						if mr.userPermissions.createNote || noteCount > 0 {
							Section("Notes (\(mr.userNotesCount ?? 0))") {
								if let projectId = project.id.toIntId(),
									mr.userPermissions.createNote
								{
									NewNoteView(projectId, iid: mr.iid, type: .mergeRequest)
								}

								if noteCount > 0 {
									ForEach(mr.notes.nodes!, id: \.self?.id) {
										maybeNote in
										if let note = maybeNote {
											NoteView(note, projectId: project.id.toIntId() ?? 0)
										}
									}
								}
							}
						}
					} else {
						NoContentView("Can't find merge request", lucide: .gitPullRequest)
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading Merge Request !\(self.iid)", lucide: .gitPullRequest, color: .blue)
			}
		}.task {
			loadMergeRequest()
		}.refreshable {
			await reloadMergeRequest()
		}.toolbar {
			if let project, case .success(let project) = project {
				if let mr = project.mergeRequest {
					HStack {
						Button(
							action: {},
							label: {
								Label(
									title: {
										Text(mr.state.rawValue.capitalized)
									},
									icon: {
										LucideLabelIcon(MergeStateHelper.getIconByState(mr.state))
									})
							}
						)
						.tint(MergeStateHelper.getColorByState(mr.state))
						.labelStyle(.titleAndIcon)
						.buttonBorderShape(.roundedRectangle)
						.buttonStyle(.borderedProminent)
						.controlSize(.mini)

						if let webUrl = mr.webUrl,
							let url = URL(string: webUrl)
						{
							ShareButton(url)
						}
					}
				}
			}
		}
		.navigationBarTitleDisplayMode(.inline)
		.scrollDismissesKeyboard(.interactively)
	}
}

#Preview {
	NavigationStack {
		MergeRequestLoader(fullPath: "felix-schindler/gitlab-ios", iid: "1")
	}
}
