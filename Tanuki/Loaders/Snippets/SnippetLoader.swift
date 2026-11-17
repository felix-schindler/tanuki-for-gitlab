//
//  SnippetLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 29.02.24.
//

import GitLabAPI
import SwiftUI
import TanukiShared

struct SnippetLoader: View {
	@Environment(\.colorScheme)
	private var colorScheme: ColorScheme

	private let id: String

	@State
	private var loader = ApolloLoader<SnippetQuery, SnippetQuery.Data.Snippets.Node> {
		$0.snippets?.nodes?.compactMap { $0 }.first
	}

	init(id: String) {
		self.id = id
	}

	public var body: some View {
		let state = loader.state

		List {
			if state.isInitialLoading {
				LoadingView("Loading Snippet", systemImage: Icons.snippets.rawValue)
			} else if state.isColdFailure, let error = state.error {
				FailedView(error)
			} else if let snippet = state.value {
				VStack(alignment: .leading) {
					HStack {
						Text(snippet.title.emojized())
							.font(.title3)
							.fontWeight(.medium)
							.padding(.bottom, 1)
						Spacer()
						Text(Date.fromToString(snippet.createdAt))
							.font(.footnote)
					}

					ScrollView(.horizontal) {
						HStack {
							if let author = snippet._author {
								AuthorView(author)
							}
							VisibilityIcon(
								snippet.visibilityLevel.rawValue,
								showText: true
							)
							.padding(.horizontal, 8)
							.padding(.vertical, 3)
							.background(Color(.systemGray5))
							.foregroundStyle(.primary)
							.cornerRadius(5)
						}.font(.footnote)
					}

					if let description = snippet.description, description.isNotEmpty {
						Markdown(description)
					}
				}

				if let blobs = snippet.blobs?.nodes, blobs.isNotEmpty {
					ForEach(blobs, id: \.self?.name) { file in
						if let file {
							Section("\(file.name ?? "File") (\(file.size) B)") {
								if let contents = file.rawPlainData?.trimmingCharacters(
									in: .whitespacesAndNewlines), contents.isNotEmpty
								{
									CodeTextView(
										contents,
										language: String(
											file.name?.split(separator: ".").last ?? "unknown"),
										colorScheme: self.colorScheme,
										fontSize: 12
									)
								}
							}
						}
					}
				}

				if let notes = snippet.notes.nodes {
					Section("Notes") {
						ForEach(notes, id: \.self?.id) { maybeNote in
							if let note = maybeNote {
								NoteView(note)
							}
						}
					}
				}
			}

		}.task {
			await loader.load(SnippetQuery(id: id))
		}.refreshable {
			await loader.reload(SnippetQuery(id: id))
		}.toolbar {
			if let snippet = loader.state.value {
				HStack {
					if let url = URL(string: snippet.webUrl) {
						ShareButton(url)
					}

					let showCloneSection =
						(snippet.httpUrlToRepo != nil || snippet.sshUrlToRepo != nil)

					if showCloneSection {
						Menu("More", systemImage: "ellipsis") {
							if let httpUrl = snippet.httpUrlToRepo {
								Button(
									"Copy HTTP url",
									systemImage: Icons.copy.rawValue
								) {
									httpUrl.copyToClipboard()
									Notify.status(
										.success, "Copied to clipboard", systemImage: "checkmark")
								}
							}

							if let sshUrl = snippet.sshUrlToRepo {
								Button(
									"Copy SSH url",
									systemImage: Icons.copy.rawValue
								) {
									sshUrl.copyToClipboard()
									Notify.status(
										.success, "Copied to clipboard", systemImage: "checkmark")
								}
							}
						}
					}
				}
			}
		}.scrollDismissesKeyboard(.interactively)
	}
}

#Preview {
	NavigationStack {
		SnippetLoader(id: "gid://gitlab/PersonalSnippet/3681071")
	}
}
