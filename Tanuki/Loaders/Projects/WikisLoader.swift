//
//  WikisLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 08.10.26.
//

import SwiftUI
import TanukiShared

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
	private var state = Loadable<[WikiPage]>()

	@State
	private var pager = RestPage()

	init(projectId: Int) {
		self.projectId = projectId
	}

	private func load(reset: Bool) async {
		if reset {
			pager.reset()
			state.isLoading = true
		} else {
			state.isLoadingMore = true
		}

		defer {
			state.isLoading = false
			state.isLoadingMore = false
		}

		do {
			let pages = try await API.get(
				type: [WikiPage].self,
				endpoint: "projects/\(projectId)/wikis",
				query: pager.query
			)

			if Task.isCancelled { return }
			state.value = (state.value ?? []) + pages
			state.error = nil
			pager.advance(pages.count)
		} catch {
			if Task.isCancelled { return }
			state.error = error
			Notify.status(.error)
		}
	}

	private func loadMore() async {
		guard pager.hasMore, !state.isLoading, !state.isLoadingMore else { return }
		await load(reset: false)
	}

	var body: some View {
		LoadableList(
			state,
			hasMore: pager.hasMore,
			emptyMessage: "This project has no wiki pages",
			emptySystemImage: "book.closed",
			loadingMessage: "Loading Wiki",
			loadingSystemImage: "book.closed",
			onLoadMore: { await loadMore() },
			onRefresh: { await load(reset: true) },
			row: { page in
				NavigationLink(
					destination: WikiPageLoader(
						projectId: projectId,
						slug: page.slug,
						title: page.title
					)
				) {
					Label(page.title.emojized(), systemImage: Icons.files.rawValue)
				}
			}
		).task {
			await load(reset: true)
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
							systemImage: Icons.files.rawValue)
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading Page", systemImage: Icons.files.rawValue)
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
