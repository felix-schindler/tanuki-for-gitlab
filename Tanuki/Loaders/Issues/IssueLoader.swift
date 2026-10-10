//
//  Issue.swift
//  Tanuki
//
//  Created by Felix Schindler on 31.10.21.
//  Rewritten by Felix Schindler on 27.02.24.
//

import GitLabAPI
import SwiftUI

struct IssueLoader: View {
	@Environment(\.dismiss) private var dismiss

	private let fullPath: String
	private let iid: String

	@State
	private var project: Result<GitLabAPI.IssueQuery.Data.Project, Error>? = nil

	@State
	private var showDeleteConfirm = false

	init(fullPath: String, iid: String) {
		self.fullPath = fullPath
		self.iid = iid
	}

	// MARK: - Data loading

	private func handleGraphQLErrors(_ errors: [any Error]?) {
		guard let errors, !errors.isEmpty else { return }

		let messages = errors.map(\.localizedDescription)
		Notify.status(
			.error, "Couldn't load issue ##\(iid)", messages.first,
			systemImage: "exclamationmark.triangle")

		if project == nil {
			self.project = .failure(
				ProjectLoadError(fullPath: "\(fullPath) ##\(iid)", messages: messages))
		}
	}

	private func loadIssue() {
		do {
			let responses = try Network.shared.apollo.fetch(
				query: IssueQuery(fullPath: self.fullPath, iid: self.iid),
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
			Notify.status(.error, "Couldn't load issue ##\(iid)", error.localizedDescription)
		}
	}

	private func reloadIssue() async {
		do {
			let response = try await Network.shared.apollo.fetch(
				query: IssueQuery(fullPath: self.fullPath, iid: self.iid),
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
							fullPath: "\(fullPath) ##\(iid)", messages: ["GitLab returned no issue."]))
				}
			}
		} catch let error {
			self.project = .failure(error)
			Notify.status(.error, "Couldn't load issue ##\(iid)", error.localizedDescription)
		}
	}

	// MARK: - Issue mutations
	private func changeState(_ state: IssueStateEvent) async {
		do {
			_ = try await Network.shared.apollo.perform(
				mutation: IssueStateMutation(
					projectPath: self.fullPath, iid: self.iid, stateEvent: GraphFilter.toFilterEnum(state))
			)
			await reloadIssue()
		} catch let error {
			Notify.status(.error, "Failed to change issue state", error.localizedDescription)
		}
	}

	private func deleteIssue(_ projectId: Int) async {
		do {
			try await API.delete(endpoint: "projects/\(projectId)/issues/\(self.iid)")
			Notify.status(.success, "Issue #\(self.iid) was deleted", systemImage: "trash")
			self.dismiss()
		} catch let error {
			Notify.status(.error, "Failed to delete issue", error.localizedDescription)
		}
	}

	public var body: some View {
		List {
			if let project {
				switch project {
				case .success(let project):
					if let issue = project.issue {
						VStack(alignment: .leading) {
							HStack(spacing: 5) {
								if let url = URL.fromAvatar(project.avatarUrl) {
									AvatarImage(url, size: .tiny)
								}
								ScrollView(.horizontal) {
									Text(issue.reference)
										.foregroundStyle(.secondary)
								}
								Spacer()
								Text(Date.fromToString(issue.createdAt))
							}
							.font(.footnote)
							.padding(.bottom, 1)

							Text(issue.title.emojized())
								.font(.title3)
								.fontWeight(.medium)
								.padding(.bottom, 1)

							ScrollView(.horizontal) {
								HStack(spacing: 5) {
									AuthorView(issue._author)

									if let dueDate = issue.dueDate {
										PillView(
											Date.fromToString(dueDate),
											icon: .alarmClock,
											bgColor: .blue,
											fgColor: .white,
											cornerRadius: 5
										)
									}
								}
								.font(.footnote)
								.monospacedDigit()
							}

							if let description = issue.description, description.isNotEmpty {
								Markdown(description)
							}

							HStack {
								VotePillsView(
									projectId: project.id.toIntId(),
									iid: self.iid,
									type: .issue,
									upvotes: issue.upvotes,
									downvotes: issue.downvotes
								) {
									await reloadIssue()
								}
							}
							.modifier(LabelSpacingIfAvailable())
							.font(.footnote)
						}

						Section("Details") {
							let assgineeCount = issue.assignees?.nodes?.count ?? 0
							DisclosureGroup(
								content: {
									if assgineeCount > 0 {
										ForEach(issue.assignees!.nodes!, id: \.self) { maybeUser in
											if let user = maybeUser {
												NavigationLink(
													destination: UserLoader(
														username: user.username
													),
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
												Text(String(assgineeCount))
											}
										},
										icon: {
											LucideLabelIcon(.circleUserRound)
										})
								}
							)

							if let labels = issue.labels?.nodes, labels.isNotEmpty {
								Label(
									title: {
										ScrollView(.horizontal) {
											HStack {
												ForEach(labels, id: \.?.title) { label in
													if let label {
														PillView(
															label.title.emojized(),
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

							if let milestone = issue.milestone {
								Label(
									milestone.title.emojized(),
									lucide: .milestone
								)
							}

							if issue.humanTimeEstimate != nil
								|| issue.humanTotalTimeSpent != nil
							{
								Label(
									title: {
										HStack {
											Text(
												"Estimate: \(issue.humanTimeEstimate ?? "none")"
											)
											Spacer()
											Text(
												"Spent: \(issue.humanTotalTimeSpent ?? "none")"
											)
										}
									},
									icon: {
										LucideLabelIcon(.hourglass)
									})
							}
						}

						if issue.userPermissions.updateIssue {
							Section("Actions") {
								if let projectId = project.id.toIntId() {
									NavigationLink(
										destination: EditTitleDescriptionView(
											projectId: projectId,
											iid: self.iid,
											type: .issue,
											initialTitle: issue.title,
											initialDescription: issue.description ?? ""
										) {
											await reloadIssue()
										}
									) {
										Label("Edit issue", lucide: .pencil)
									}
								}

								if issue.state == .opened {
									AsyncButton("Close issue", lucide: .circleDot) {
										await self.changeState(.close)
									}.tint(.blue)
								} else if issue.state == .closed {
									AsyncButton("Reopen issue", lucide: .rotateCw) {
										await self.changeState(.reopen)
									}.tint(.green)
								}

								if let projectId = project.id.toIntId() {
									Button("Delete issue", lucide: .trash, role: .destructive) {
										self.showDeleteConfirm = true
									}.confirmationDialog(
										"Are you sure you want to delete issue #\(self.iid)?",
										isPresented: $showDeleteConfirm, titleVisibility: .visible
									) {
										AsyncButton("Delete", role: .destructive) {
											await self.deleteIssue(projectId)
										}
										Button("Cancel", role: .cancel) {
											showDeleteConfirm = false
										}
									}.tint(.red)
								}
							}
						}

						let noteCount = issue.notes.nodes?.count ?? 0
						if issue.userPermissions.createNote || noteCount > 0 {
							Section("Notes (\(issue.userNotesCount))") {
								if let projectId = project.id.toIntId(),
									issue.userPermissions.createNote
								{
									NewNoteView(projectId, iid: issue.iid, type: .issue)
								}

								if noteCount > 0 {
									ForEach(issue.notes.nodes!, id: \.self?.id) { maybeNote in
										if let note = maybeNote {
											NoteView(note, projectId: project.id.toIntId() ?? 0)
										}
									}
								}
							}
						}
					} else {
						NoContentView(
							"Issue was not found", lucide: .circleDot)
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView(
					"Loading Issue #\(self.iid)", lucide: .circleDot, color: .green)
			}
		}.task {
			loadIssue()
		}.refreshable {
			await reloadIssue()
		}.toolbar {
			if let project, case .success(let project) = project,
				let issue = project.issue
			{
				HStack {
					Button(
						issue.state.rawValue.capitalized,
						lucide: IssueStateHelper.getIconByState(issue.state),
					) {}
					.tint(IssueStateHelper.getColorByState(issue.state))
					.labelStyle(.titleAndIcon)
					.buttonBorderShape(.roundedRectangle)
					.buttonStyle(.borderedProminent)
					.controlSize(.mini)

					if let url = URL(string: issue.webUrl) {
						ShareButton(url)
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
		IssueLoader(fullPath: "felix-schindler/gitlab-ios", iid: "111")
	}
}
