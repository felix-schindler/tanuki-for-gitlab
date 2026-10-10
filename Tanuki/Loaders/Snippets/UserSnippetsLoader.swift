//
//  UserSnippetsLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 29.02.24.
//

import GitLabAPI
import SwiftUI

struct UserSnippetsLoader: View {
	private let username: String?

	@State
	private var snippets: Result<[Snippet?], Error>? = nil

	@State
	private var createSnippet = false

	init(username: String? = nil) {
		self.username = username
	}

	private func loadSnippets() {
		do {
			if let username {
				let responses = try Network.shared.apollo.fetch(
					query: UserSnippetsQuery(username: username),
					cachePolicy: .cacheAndNetwork
				)

				Task {
					for try await response in responses {
						if let snippets = response.data?.user?.snippets?.nodes {
							self.snippets = .success(snippets)
						} else if let errors = response.errors {
							for error in errors {
								Notify.status(.error, error.localizedDescription)
							}
						}
					}
				}
			} else {
				let responses = try Network.shared.apollo.fetch(
					query: CurrentUserSnippetsQuery(),
					cachePolicy: .cacheAndNetwork
				)

				Task {
					for try await response in responses {
						if let snippets = response.data?.currentUser?.snippets?.nodes {
							self.snippets = .success(snippets)
						} else if let errors = response.errors {
							for error in errors {
								Notify.status(.error, error.localizedDescription)
							}
						}
					}
				}
			}
		} catch let error {
			self.snippets = .failure(error)
			Notify.status(.error)
		}
	}

	private func reloadSnippets() async {
		do {
			if let username {
				let response = try await Network.shared.apollo.fetch(
					query: UserSnippetsQuery(username: username),
					cachePolicy: .networkOnly
				)

				if let snippets = response.data?.user?.snippets?.nodes {
					self.snippets = .success(snippets)
				}
			} else {
				let response = try await Network.shared.apollo.fetch(
					query: CurrentUserSnippetsQuery(),
					cachePolicy: .networkOnly
				)

				if let snippets = response.data?.currentUser?.snippets?.nodes {
					self.snippets = .success(snippets)
				}
			}

			Notify.status(.success)
		} catch let error {
			self.snippets = .failure(error)
			Notify.status(.error)
		}
	}

	public var body: some View {
		List {
			if let snippets {
				switch snippets {
				case .success(let snippets):
					if snippets.isEmpty {
						NoContentView("There are no snippets", systemImage: "scissors")
					} else {
						ForEach(snippets, id: \.self?.id) { maybeSnippet in
							if let snippet = maybeSnippet {
								NavigationLink(
									destination: SnippetLoader(id: snippet.id),
									label: {
										HStack {
											VStack(alignment: .leading) {
												HStack {
													VisibilityIcon(
														snippet
															.visibilityLevel
															.rawValue
													)
													Text(snippet.title.emojized())
												}

												ScrollView(.horizontal) {
													HStack {
														if let author = snippet
															._author
														{
															AuthorView(author)
														}

														PillView(Date.fromToString(snippet.createdAt), icon: "clock")
													}.font(.footnote)
												}
											}
										}.swipeActions {
											ShareButton(URL(string: snippet.webUrl)!)
										}
									}
								)
							}
						}
					}
				case .failure(let error):
					FailedView(error.localizedDescription, icon: "scissors")
				}
			} else {
				LoadingView("Loading Snippets", systemImage: "scissors")
			}
		}.task {
			loadSnippets()
		}.refreshable {
			await reloadSnippets()
		}.toolbar {
			if username == nil {
				Button("New snippet", systemImage: "plus") {
					createSnippet = true
				}
			}
		}.navigationDestination(isPresented: $createSnippet) {
			NewSnippetView()
		}.navigationTitle("Snippets")
	}
}

#Preview {
	NavigationStack {
		UserSnippetsLoader(username: "felix-schindler")
	}
}
