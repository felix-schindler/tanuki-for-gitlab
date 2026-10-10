//
//  NewIssueView.swift
//  Tanuki
//
//  Created by Felix Schindler on 10.09.25.
//

import GitLabAPI
import HighlightedTextEditor
import SwiftUI

enum IssueType: String, CaseIterable {
	case issue = "issue"
	case incident = "incident"
	case testCase = "test_case"
	case task = "task"
}

struct NewIssueView: View {
	@Environment(\.dismiss) private var dismiss

	private let id: Int
	private let fullPath: String

	init(id: Int, fullPath: String) {
		self.id = id
		self.fullPath = fullPath
	}

	@State private var tags: [Tag]? = nil
	@State private var memberships: Result<[Member?], Error>? = nil
	@State private var milestones: [ProjectMilestonesQuery.Data.Project.Milestones.Node?]? = nil
	@State private var labels: [MyLabel?]? = nil

	@State private var title = ""
	@State private var description = ""
	@State private var selectedAssignees: Set<String> = []
	@State private var type = IssueType.issue
	@State private var confidential = false
	@State private var setDueDate = false
	@State private var dueDate = SwiftUI.Date()
	@State private var selectedLabels: Set<String> = []
	@State private var selectedMilestone = ""
	@State private var weight = -1

	private func loadMembers() async {
		do {
			let response = try await Network.shared.apollo.fetch(
				query: ProjectMembersQuery(fullPath: self.fullPath),
				cachePolicy: .networkOnly
			)

			if let memberships = response.data?.project?.projectMembers?.nodes {
				self.memberships = .success(memberships)
			}
		} catch let error {
			self.memberships = .failure(error)
		}
	}

	private func loadMilestones() async {
		do {
			let response = try await Network.shared.apollo.fetch(
				query: ProjectMilestonesQuery(
					fullPath: self.fullPath,
					state: .none,
					searchTitle: .none,
					includeAncestors: .some(false)
				),
				cachePolicy: .networkOnly
			)

			if let milestones = response.data?.project?.milestones?.nodes {
				self.milestones = milestones
			}
		} catch let error {
			Notify.status(
				.error,
				"Couldn't load milestones",
				error.localizedDescription,
				systemImage: "exclamationmark.triangle"
			)
		}
	}

	private func loadLabels() async {
		do {
			let response = try await Network.shared.apollo.fetch(
				query: ProjectLabelsQuery(fullPath: self.fullPath), cachePolicy: .networkOnly)

			if let labels = response.data?.project?.labels?.nodes {
				self.labels = labels
			}
		} catch let error {
			Notify.status(
				.error,
				"Couldn't load labels",
				error.localizedDescription,
				systemImage: "exclamationmark.triangle"
			)
		}
	}

	private func createIssue() async {
		var body: [String: EncodableValue] = [:]

		if title.isEmpty {
			Notify.status(.error, "Please enter a title.")
			return
		} else {
			body["title"] = .string(title)
		}

		body["issue_type"] = .string(type.rawValue)

		if description.isNotEmpty {
			body["description"] = .string(description)
		}

		if selectedAssignees.isNotEmpty {
			let ids = selectedAssignees.compactMap { $0.toIntId() }

			if ids.isNotEmpty {
				body["assignee_id"] = .int(ids.first!)
				body["assignee_ids"] = .intArray(ids)
			}
		}

		if confidential {
			body["confidential"] = .boolean(true)
		}

		if setDueDate {
			let inputFormatter = DateFormatter()
			inputFormatter.dateFormat = "yyyyMMdd"

			body["due_date"] = .string(inputFormatter.string(from: dueDate))
		}

		if selectedLabels.isNotEmpty {
			body["labels"] = .array(Array(selectedLabels))
		}

		if selectedMilestone.isNotEmpty {
			body["milestone_id"] = .string(selectedMilestone)
		}

		if weight >= 0 {
			body["weight"] = .string(String(weight))
		}

		do {
			let temp = try await API.req(
				type: RestAPIIssue.self,
				method: .post,
				endpoint: "projects/\(self.id)/issues",
				body: body
			)

			Notify.status(.success, "Issue #\(temp.iid) created")
			self.dismiss()
		} catch let error {
			Notify.status(.error, "Failed to create new issue", error.localizedDescription)
		}
	}

	var body: some View {
		Form {
			TextField("Title (required)", text: $title)

			Section("Description (Markdown supported)") {
				HighlightedTextEditor(text: $description, highlightRules: .markdown)
					.frame(minHeight: 100)
			}

			Section {
				if let memberships {
					switch memberships {
					case .success(let memberships):
						if memberships.isEmpty {
							NoContentView("There are no project members", lucide: .users)
						} else {
							Menu("Select Assignees") {
								ForEach(memberships, id: \.?.id) { member in
									if let member {
										Button {
											if selectedAssignees.contains(member.id) {
												selectedAssignees.remove(member.id)
											} else {
												selectedAssignees.insert(member.id)
											}
										} label: {
											if selectedAssignees.contains(member.id) {
												if let username = member._user?.username {
													Label("@\(username)", lucide: .check)
												} else {
													Label(member.id, lucide: .check)
												}
											} else {
												if let username = member._user?.username {
													Text("@\(username)")
												} else {
													Text(member.id)
												}
											}
										}
									}
								}
							}
						}
					case .failure(let error):
						FailedView(error)
					}
				} else {
					LoadingView("Loading project members", lucide: .users)
				}
			}

			Section {
				Picker("Type", selection: $type) {
					ForEach(IssueType.allCases, id: \.rawValue) { type in
						Text(type.rawValue.capitalized.replacing("_", with: " "))
							.tag(type)
					}
				}
				VStack(alignment: .leading) {
					Toggle("Confidential", isOn: $confidential)
					Text("Limit visibility to project members with at least the Planner role.")
						.foregroundStyle(.secondary)
						.font(.footnote)
				}
				VStack(alignment: .leading) {
					Toggle("Set due date", isOn: $setDueDate)
					if setDueDate {
						DatePicker("Due date", selection: $dueDate, displayedComponents: .date)
					}
				}

				if let labels, labels.isNotEmpty {
					Menu("Select Labels") {
						ForEach(labels, id: \.?.title) { label in
							if let label {
								Button {
									if selectedLabels.contains(label.title) {
										selectedLabels.remove(label.title)
									} else {
										selectedLabels.insert(label.title)
									}
								} label: {
									if selectedLabels.contains(label.title) {
										Label(label.title.emojized(), lucide: .check)
									} else {
										Text(label.title.emojized())
									}
								}
							}
						}
					}
				} else {
					Text("There are no Labels")
				}

				if let milestones, milestones.isNotEmpty {
					Picker("Milestone", selection: $selectedMilestone) {
						ForEach(milestones, id: \.?.iid) { milestone in
							if let milestone {
								Text(milestone.title)
									.tag(milestone.iid)
							}
						}
					}
				} else {
					Text("There are no Milestones")
				}
				Stepper("Weight: \(weight < 0 ? "none" : String(weight))", value: $weight)
			}
		}.toolbar {
			AsyncButton("Create issue", lucide: .check) {
				await createIssue()
			}.tint(.accentColor)
		}.task {
			await loadMembers()
			await loadMilestones()
			await loadLabels()
		}.refreshable {
			await loadMembers()
			await loadMilestones()
			await loadLabels()
		}
		.navigationTitle("New Issue")
		.scrollDismissesKeyboard(.interactively)
	}
}

#Preview {
	NavigationStack {
		NewIssueView(id: 278_964, fullPath: "gitlab-org/gitlab")
	}
}
