//
//  ProjectSnippetsLoader.swift
//  Tanuki
//

import GitLabAPI
import SwiftUI

struct ProjectSnippetsLoader: View {
	/// Path of project to load snippets from
	private let fullPath: String
	private let projectId: Int

	@State
	private var snippets: Result<[ProjectSnippetsQuery.Data.Project.Snippets.Node?], Error>? = nil

	@State
	private var createSnippet = false

	init(fullPath: String, projectId: Int) {
		self.fullPath = fullPath
		self.projectId = projectId
	}

	private func loadSnippets() {
		do {
			let responses = try Network.shared.apollo.fetch(
				query: ProjectSnippetsQuery(fullPath: self.fullPath),
				cachePolicy: .cacheAndNetwork
			)

			Task {
				for try await response in responses {
					if let snippets = response.data?.project?.snippets?.nodes {
						self.snippets = .success(snippets)
					} else if let errors = response.errors {
						for error in errors {
							Notify.status(.error, error.localizedDescription)
						}
					}
				}
			}
		} catch let error {
			self.snippets = .failure(error)
			Notify.status(.error)
		}
	}

	private func reloadSnippets(notify: Bool = true) async {
		do {
			let response = try await Network.shared.apollo.fetch(
				query: ProjectSnippetsQuery(fullPath: self.fullPath),
				cachePolicy: .networkOnly
			)

			if let snippets = response.data?.project?.snippets?.nodes {
				self.snippets = .success(snippets)
			}

			if notify {
				Notify.status(.success)
			}
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
			Button("New snippet", systemImage: "plus") {
				createSnippet = true
			}
		}.navigationDestination(isPresented: $createSnippet) {
			NewSnippetView(
				projectId: self.projectId,
				onCreated: {
					await reloadSnippets(notify: false)
				})
		}.navigationTitle("Snippets")
	}
}

#Preview {
	NavigationStack {
		ProjectSnippetsLoader(fullPath: "felix-schindler/gitlab-ios", projectId: 43_985_992)
	}
}
