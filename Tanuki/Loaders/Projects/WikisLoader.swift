//
//  WikisLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 08.10.26.
//

import SwiftUI

struct WikiPage: Codable, Identifiable {
	var id: String { slug }
	let slug: String
	let title: String
	let format: String
	let content: String?
}

struct WikisLoader: View {
	private let projectId: Int

	@State
	private var pages: Result<[WikiPage], Error>? = nil

	init(projectId: Int) {
		self.projectId = projectId
	}

	private func loadPages() async {
		do {
			pages = .success(
				try await API.get(
					type: [WikiPage].self,
					endpoint: "projects/\(projectId)/wikis"
				))
		} catch {
			pages = .failure(error)
			Notify.status(.error)
		}
	}

	var body: some View {
		List {
			if let pages {
				switch pages {
				case .success(let pages):
					if pages.isEmpty {
						NoContentView(
							"This project has no wiki pages",
							lucide: .bookOpen)
					} else {
						ForEach(pages) { page in
							NavigationLink(
								destination: WikiPageLoader(
									projectId: projectId,
									slug: page.slug,
									title: page.title
								)
							) {
								Label(page.title.emojized(), lucide: .fileText)
							}
						}
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading Wiki", lucide: .bookOpen)
			}
		}.task {
			await loadPages()
		}.refreshable {
			await loadPages()
		}.navigationTitle("Wiki")
	}
}

struct WikiPageLoader: View {
	private let projectId: Int
	private let slug: String
	private let title: String

	@State
	private var page: Result<WikiPage, Error>? = nil

	init(projectId: Int, slug: String, title: String? = nil) {
		self.projectId = projectId
		self.slug = slug
		self.title = title ?? slug
	}

	private func loadPage() async {
		do {
			page = .success(
				try await API.req(
					type: WikiPage.self,
					method: .get,
					endpoint: "projects/\(projectId)/wikis",
					resource: slug
				))
		} catch {
			page = .failure(error)
			Notify.status(.error)
		}
	}

	var body: some View {
		List {
			if let page {
				switch page {
				case .success(let page):
					if let content = page.content, content.isNotEmpty {
						Markdown(content, baseURL: API.url)
					} else {
						NoContentView(
							"This page is empty",
							lucide: .fileText)
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading Page", lucide: .fileText)
			}
		}.task {
			await loadPage()
		}.refreshable {
			await loadPage()
		}.navigationTitle(title.emojized())
	}
}

#Preview {
	NavigationStack {
		WikisLoader(projectId: 33_025_310)
	}
}
