//
//  SnippetLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 29.02.24.
//

import GitLabAPI
import SwiftUI

struct SnippetLoader: View {
	@Environment(\.colorScheme)
	private var colorScheme: ColorScheme

	private let id: String

	@State
	private var snippet: Result<SnippetQuery.Data.Snippets.Node, Error>? = nil

	init(id: String) {
		self.id = id
	}

	private func loadSnippet() {
		do {
			let responses = try Network.shared.apollo.fetch(
				query: SnippetQuery(id: self.id),
				cachePolicy: .cacheAndNetwork
			)

			Task {
				for try await response in responses {
					if let snippet = response.data?.snippets?.nodes?.compactMap({ $0 }).first {
						self.snippet = .success(snippet)
					} else if let errors = response.errors {
						for error in errors {
							Notify.status(.error, error.localizedDescription)
						}
					}
				}
			}
		} catch let error {
			self.snippet = .failure(error)
			Notify.status(.error)
		}
	}

	private func reloadSnippet() async {
		do {
			let response = try await Network.shared.apollo.fetch(
				query: SnippetQuery(id: self.id),
				cachePolicy: .networkOnly
			)

			if let snippet = response.data?.snippets?.nodes?.compactMap({ $0 }).first {
				self.snippet = .success(snippet)
			}

			Notify.status(.success)
		} catch let error {
			self.snippet = .failure(error)
			Notify.status(.error)
		}
	}

	public var body: some View {
		List {
			if let snippet {
				switch snippet {
				case .success(let snippet):
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
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading Snippet", lucide: .scissors)
			}
		}.task {
			loadSnippet()
		}.refreshable {
			await reloadSnippet()
		}.toolbar {
			if let snippet, case .success(let snippet) = snippet {
				HStack {
					if let url = URL(string: snippet.webUrl) {
						ShareButton(url)
					}

					let showCloneSection =
						(snippet.httpUrlToRepo != nil || snippet.sshUrlToRepo != nil)

					if showCloneSection {
						Menu("More", lucide: .ellipsis) {
							if let httpUrl = snippet.httpUrlToRepo {
								Button(
									"Copy HTTP url",
									lucide: .copy
								) {
									httpUrl.copyToClipboard()
									Notify.status(
										.success, "Copied to clipboard", systemImage: "checkmark")
								}
							}

							if let sshUrl = snippet.sshUrlToRepo {
								Button(
									"Copy SSH url",
									lucide: .copy
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
