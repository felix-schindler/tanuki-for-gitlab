//
//  TagsView.swift
//  GitLab
//
//  Created by Felix Schindler on 05.05.23.
//

import SwiftUI

struct Tag: Codable {
	let name: String
	let message: String  // Empty string if not set
	let target: String
	let commit: Commit
	let protected: Bool
}

struct TagsLoader: View {
	private let projectId: Int

	@State
	private var tags: Result<[Tag], Error>? = nil

	init(_ projectId: Int) {
		self.projectId = projectId
	}

	private func loadTags() async {
		do {
			let temp = try await API.get(
				type: [Tag].self,
				endpoint: "projects/\(projectId)/repository/tags"
			)

			self.tags = .success(temp)
		} catch let error {
			self.tags = .failure(error)
			Notify.status(.error)
		}
	}

	public var body: some View {
		List {
			if let tags {
				switch tags {
				case .success(let tags):
					if tags.isEmpty {
						NoContentView(
							"You'll see your tags after you pushed them",
							systemImage: "chevron.left.forwardslash.chevron.right")
					} else {
						ForEach(tags, id: \.name) { tag in
							VStack(alignment: .leading) {
								Text(tag.name.emojized())
									.fontWeight(.medium)

								if tag.message.isNotEmpty {
									InlineMarkdown(tag.message)
								}

								ScrollView(.horizontal) {
									HStack {
										PillView(tag.commit.shortId)
											.font(.system(.footnote, design: .monospaced))
										PillView(tag.commit.authoredDate.toString(), icon: "clock")
									}
								}.font(.footnote)
								InlineMarkdown(tag.commit.title.emojized())
									.font(.footnote)
							}
						}
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading Tags", systemImage: "chevron.left.forwardslash.chevron.right")
			}
		}.task {
			await loadTags()
		}.refreshable {
			await loadTags()
		}.toolbar {
			NavigationLink(destination: NewTagView(projectId: projectId)) {
				Label("New tag", systemImage: "plus")
			}.tint(.accentColor)
		}.navigationTitle("Tags")
	}
}

#Preview {
	NavigationStack {
		TagsLoader(33_025_310)
	}
}
