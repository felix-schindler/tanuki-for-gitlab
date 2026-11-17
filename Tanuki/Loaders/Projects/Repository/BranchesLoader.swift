//
//  BranchesLoader.swift
//  GitLab
//
//  Created by Felix Schindler on 02.11.21.
//

import SwiftUI
import TanukiShared

struct BranchesLoader: View {
	private var projectId: Int

	@State
	private var state = Loadable<[Branch]>()

	@State
	private var pager = RestPage()

	init(_ projectId: Int) {
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
			let branches = try await API.get(
				type: [Branch].self,
				endpoint: "projects/\(projectId)/repository/branches",
				query: pager.query
			)

			if Task.isCancelled { return }
			state.value = reset ? branches : (state.value ?? []) + branches
			state.error = nil
			pager.advance(branches.count)
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

	public var body: some View {
		LoadableList(
			state,
			hasMore: pager.hasMore,
			emptyMessage: "You'll see your branches after you pushed them",
			emptySystemImage: Icons.code.rawValue,
			loadingMessage: "Loading Branches",
			loadingSystemImage: Icons.code.rawValue,
			onLoadMore: { await loadMore() },
			onRefresh: { await load(reset: true) },
			row: { branch in
				VStack(alignment: .leading) {
					HStack {
						if branch.protected {
							Image(systemName: Icons.lock.rawValue)
						}
						Text(branch.name.emojized())
							.font(.headline)
					}

					ScrollView(.horizontal) {
						HStack {
							PillView(branch.commit.shortId)
								.font(.system(.footnote, design: .monospaced))
							PillView(branch.commit.authoredDate.toString(), icon: Icons.clock.rawValue)
						}
					}.font(.footnote)
					Text(branch.commit.title.emojized())
						.font(.footnote)
				}
			}
		).task {
			await load(reset: true)
		}.toolbar {
			NavigationLink(destination: NewBranchView(projectId: projectId)) {
				Label("New branch", systemImage: "plus")
			}.tint(.accentColor)
		}.navigationTitle("Branches")
	}
}

#Preview {
	NavigationStack {
		BranchesLoader(33_025_310)
	}
}
