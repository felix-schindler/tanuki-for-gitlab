//
//  ProjectReleasesLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 04.03.24.
//

import GitLabAPI
import SwiftUI

struct ProjectReleasesLoader: View {
	private var fullPath: String
	private var projectId: Int?

	@State
	private var pager = PagedQuery<ProjectReleasesQuery, ProjectReleasesQuery.Data.Project.Releases.Node>(
		extract: { ($0.project?.releases?.nodes ?? []).compactMap { $0 } },
		key: { $0.id },
		hasNext: { $0.project?.releases?.pageInfo.hasNextPage ?? false },
		endCursor: { $0.project?.releases?.pageInfo.endCursor }
	)

	init(fullPath: String, projectId: Int? = nil) {
		self.fullPath = fullPath
		self.projectId = projectId
	}

	private func query(after: GraphQLNullable<String> = .none) -> ProjectReleasesQuery {
		ProjectReleasesQuery(first: 50, after: after, fullPath: fullPath)
	}

	private func assetFileName(directAssetPath: String?, linkName: String?, url: URL) -> String? {
		if let directAssetPath, directAssetPath.isNotEmpty {
			let name = URL(fileURLWithPath: directAssetPath).lastPathComponent
			if name.isNotEmpty {
				return name
			}
		}

		let name = url.lastPathComponent
		if name.isNotEmpty {
			return name
		}

		return linkName
	}

	@ViewBuilder
	private func assetRow(name: String?, urlString: String?, directAssetPath: String?) -> some View {
		if let urlString, let url = URL(string: urlString) {
			DownloadButton(
				url: url,
				fileName: assetFileName(
					directAssetPath: directAssetPath, linkName: name, url: url)
			) {
				Label(name ?? url.lastPathComponent, systemImage: Icons.download.rawValue)
			}
		} else {
			Text(name ?? "Link")
		}
	}

	@ViewBuilder
	private func sourceRow(format: String?, urlString: String?) -> some View {
		if let urlString, let url = URL(string: urlString) {
			DownloadButton(url: url) {
				Label(
					"Source code (\(format ?? "unknown"))",
					systemImage: Icons.archive.rawValue)
			}
		}
	}

	public var body: some View {
		LoadableList(
			pager.state,
			hasMore: pager.hasMore,
			emptyMessage: "There are no releases",
			emptySystemImage: Icons.flag.rawValue,
			loadingMessage: "Loading Releases",
			loadingSystemImage: Icons.flag.rawValue,
			onLoadMore: { await pager.loadMore() },
			onRefresh: { await pager.refresh() }
		) { release in
			Section(
				content: {
					VStack(alignment: .leading) {
						ScrollView(.horizontal) {
							HStack {
								if let author = release._author {
									AuthorView(author)
								}

								if let releasedAt = release.releasedAt {
									PillView(
										Date.fromToString(releasedAt, timeStyle: .short),
										icon: Icons.clock.rawValue)
								}

								if let tagName = release.tagName {
									PillView(tagName, icon: Icons.tag.rawValue)
								}

								if let milestones = release.milestones?.nodes {
									ForEach(milestones, id: \.?.id) {
										maybeMilestone in
										if let milestone = maybeMilestone {
											PillView(
												milestone.title.emojized(),
												icon: Icons.milestones.rawValue
											)
										}
									}
								}

								if let commit = release.commit?.shortId {
									PillView(
										commit,
										icon:
											"text.line.first.and.arrowtriangle.forward"
									)
									.textSelection(.enabled)
									.font(
										.system(.footnote, design: .monospaced))
								}
							}.font(.footnote)
						}

						if let description = release.description, description.isNotEmpty {
							Markdown(description, baseURL: API.url)
						}
					}
					if let assets = release.assets {
						DisclosureGroup(
							"Assets (\(assets.count ?? 0))",
							content: {
								if let links = assets.links?.nodes {
									ForEach(links, id: \.?.id) { maybeLink in
										if let link = maybeLink {
											let urlString =
												link.directAssetUrl
												?? link.url

											assetRow(
												name: link.name,
												urlString: urlString,
												directAssetPath: link
													.directAssetPath
											)
										}
									}
								}
								if let sources = assets.sources?.nodes {
									ForEach(sources, id: \.?.url) {
										maybeSource in
										if let source = maybeSource {
											sourceRow(
												format: source.format,
												urlString: source.url)
										}
									}
								}
							}
						)
					}
				},
				header: {
					Text(release.name?.emojized() ?? release.id)
				})
		}.task {
			await pager.start(query(), setCursor: { $0.after = .some($1) })
		}.toolbar {
			if let projectId {
				NavigationLink(
					destination: NewReleaseView(id: projectId, fullPath: self.fullPath),
					label: {
						Label("Create new release", systemImage: "plus")
					}
				).tint(.accentColor)
			}
		}
		.headerProminence(.increased)
		.navigationTitle("Releases")
	}
}

#Preview {
	NavigationStack {
		ProjectReleasesLoader(fullPath: "felix-schindler/gitlab-ios")
	}
}
