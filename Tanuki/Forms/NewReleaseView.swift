//
//  NewReleaseView.swift
//  Tanuki
//
//  Created by Felix Schindler on 20.09.25.
//

import GitLabAPI
import HighlightedTextEditor
import SwiftUI

struct NewReleaseView: View {
	@Environment(\.dismiss) private var dismiss

	private let id: Int
	private let fullPath: String

	init(id: Int, fullPath: String) {
		self.id = id
		self.fullPath = fullPath
	}

	@State private var tags: [Tag]? = nil
	@State private var milestones: [ProjectMilestonesQuery.Data.Project.Milestones.Node?]? = nil

	@State private var tagName = ""
	@State private var newTagName = false
	@State private var newTagMessage = ""
	@State private var newTagRef = ""
	@State private var releaseName = ""
	@State private var selectedMilestones: Set<String> = []
	@State private var setReleaseDate = false
	@State private var releaseDate = SwiftUI.Date()
	@State private var description = ""

	private func loadTags() async {
		do {
			let temp = try await API.get(
				type: [Tag].self,
				endpoint: "projects/\(id)/repository/tags"
			)

			self.tags = temp
			if temp.isNotEmpty {
				self.tagName = temp[0].name
			}
		} catch let error {
			Notify.status(
				.error, "Couldn't load tags",
				error.localizedDescription,
				systemImage: "exclamationmark.triangle"
			)
		}
	}

	private func loadMilestones() async {
		do {
			let response = try await Network.shared.apollo.fetch(
				query: ProjectMilestonesQuery(
					fullPath: self.fullPath, state: .none, searchTitle: .none, includeAncestors: .some(false)),
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

	private func createNewRelease() async {
		var body: [String: EncodableValue] = [:]

		if tagName.isNotEmpty {
			body["tag_name"] = .string(tagName)
		} else {
			Notify.status(.error, "There is no tag name")
			return
		}

		if newTagName {
			guard newTagRef.isNotEmpty else {
				Notify.status(.error, "There is no ref name")
				return
			}
			body["ref"] = .string(newTagRef)

			if newTagMessage.isNotEmpty {
				body["tag_message"] = .string(newTagMessage)
			}
		}

		if releaseName.isNotEmpty {
			body["name"] = .string(releaseName)
		}

		if description.isNotEmpty {
			body["description"] = .string(description)
		}

		if selectedMilestones.isNotEmpty {
			body["milestones"] = .array(Array(selectedMilestones))
		}

		if setReleaseDate {
			body["released_at"] = .string(ISO8601DateFormatter().string(from: releaseDate))
		}

		do {
			_ = try await API.req(
				type: RestAPIRelease.self,
				method: .post,
				endpoint: "projects/\(id)/releases",
				body: body
			)

			self.dismiss()
		} catch let error {
			Notify.status(
				.error, "Couldn't create new Release", error.localizedDescription,
				systemImage: "exclamationmark.triangle")
		}
	}

	public var body: some View {
		Form {
			Section("Tag name (required)") {
				Toggle("Create new tag name", isOn: $newTagName)
					.onChange(of: newTagName) { _, newValue in
						if newValue {
							self.tagName = ""
						} else if let tags, tags.isNotEmpty {
							self.tagName = tags[0].name
						}
					}
				if !newTagName, let tags, tags.isNotEmpty {
					Picker("Tag", selection: $tagName) {
						ForEach(tags, id: \.name) { tag in
							Text(tag.name)
								.tag(tag.name)
						}
					}
				} else if newTagName {
					TextField("Tag name", text: $tagName)
						.textInputAutocapitalization(.never)
						.autocorrectionDisabled()
					VStack(alignment: .leading) {
						TextField("Tag message (optional)", text: $newTagMessage)
							.textInputAutocapitalization(.never)
							.autocorrectionDisabled()
						Text("Message to use if creating a new annotated tag.")
							.foregroundStyle(.secondary)
							.font(.footnote)
					}
					VStack(alignment: .leading) {
						TextField("Ref", text: $newTagRef)
							.textInputAutocapitalization(.never)
							.autocorrectionDisabled()
						Text("It can be a commit SHA, another tag name, or a branch name.")
							.foregroundStyle(.secondary)
							.font(.footnote)
					}
				} else {
					VStack(alignment: .leading) {
						TextField("Tag name", text: $tagName)
							.textInputAutocapitalization(.never)
							.autocorrectionDisabled()
						Text("Enter an existing tag name.")
							.foregroundStyle(.secondary)
							.font(.footnote)
					}
				}
			}

			Section("Release title") {
				VStack(alignment: .leading) {
					TextField("Title", text: $releaseName)
					Text("Leave blank to use the tag name as the release title.")
						.foregroundStyle(.secondary)
						.font(.footnote)
				}
			}

			Section("Milestones") {
				if let milestones, milestones.isNotEmpty {
					Menu("Milestones") {
						ForEach(milestones, id: \.?.iid) { milestone in
							if let milestone {
								Button {
									if selectedMilestones.contains(milestone.title) {
										selectedMilestones.remove(milestone.title)
									} else {
										selectedMilestones.insert(milestone.title)
									}
								} label: {
									if selectedMilestones.contains(milestone.title) {
										Label(milestone.title, lucide: .check)
									} else {
										Text(milestone.title)
									}
								}
							}
						}
					}
				} else {
					Text("There are no active Milestones")
				}
			}

			Section("Release date") {
				Toggle("Set date when the release is ready", isOn: $setReleaseDate)
				if setReleaseDate {
					VStack(alignment: .leading) {
						DatePicker(
							"Release date", selection: $releaseDate, displayedComponents: .date)
						Text(
							"A release with a date in the future is labeled as an Upcoming Release."
						)
						.foregroundStyle(.secondary)
						.font(.footnote)
					}
				}
			}

			Section("Release notes (Markdown supported)") {
				HighlightedTextEditor(text: $description, highlightRules: .markdown)
					.frame(minHeight: 100)
			}
		}.toolbar {
			AsyncButton("Create new release", lucide: .check) {
				await createNewRelease()
			}.tint(.accentColor)
		}.task {
			await loadTags()
			await loadMilestones()
		}.refreshable {
			await loadTags()
			await loadMilestones()
		}.navigationTitle("New Release")
	}
}

#Preview {
	NavigationStack {
		NewReleaseView(id: 278_964, fullPath: "gitlab-org/gitlab")
	}
}
