//
//  Project.swift
//  Tanuki
//
//  Created by Felix Schindler on 31.10.21.
//  Rewritten by Felix Schindler on 14.03.23 and 26.02.24.
//

import GitLabAPI
import SwiftUI
import TanukiShared

enum NavDest {
	case issue,
		mergeRequest,
		milestone,
		release,
		member,
		groupShare,
		label,
		snippet
}

struct ProjectLoadError: LocalizedError {
	let fullPath: String
	let messages: [String]

	var errorDescription: String? {
		let detail = messages.first ?? "GitLab returned no project."
		return "Couldn't load “\(fullPath)”: \(detail)"
	}
}

private struct SpecialFile {
	let name: String
	let content: String
	let showsImages: Bool

	init?(name: String, content: String?, showsImages: Bool) {
		guard let content else { return nil }
		self.name = name
		self.content = content
		self.showsImages = showsImages
	}
}

struct ProjectLoader: View {
	private let fullPath: String

	@State
	private var loader = ApolloLoader<ProjectQuery, ProjectQuery.Data.Project> { $0.project }

	/// Selected special file (README, LICENSE, ...)
	@State
	private var selectedFile = 0

	@State
	private var navigationActive = false

	@State
	private var navigationDestination: NavDest? = nil

	init(fullPath: String) {
		self.fullPath = fullPath
	}

	private func requestAccess(_ projectId: Int) async {
		do {
			_ = try await API.req(
				type: RestAPIProject.self, method: .post, endpoint: "projects/\(projectId)/access_requests")
			Notify.status(.success, "Access request sent", systemImage: "checkmark")
		} catch {
			Notify.status(.error, "Access request failed", error.localizedDescription, systemImage: "xmark")
		}
	}

	private func downloadArchive(_ projectId: Int, ref: String?) async {
		do {
			var query: [String: String] = [:]
			if let ref {
				query["sha"] = ref
			}
			let fileName = "\(self.fullPath.components(separatedBy: "/").last ?? "archive").zip"
			let url = try await API.download(
				to: { _, _ in
					(
						FileCache.destination(for: fileName),
						[.createIntermediateDirectories, .removePreviousFile]
					)
				},
				method: .get,
				endpoint: "projects/\(projectId)/repository/archive.zip",
				query: query
			)
			FileCache.purge()
			Notify.status(.success, "Archive downloaded", systemImage: "checkmark")
			ShareSheet.present(for: url)
		} catch {
			Notify.status(.error, "Download failed", error.localizedDescription, systemImage: "xmark")
		}
	}

	public var body: some View {
		List {
			let state = loader.state
			if state.isInitialLoading {
				LoadingView("Loading Project \(self.fullPath)", systemImage: Icons.projects.rawValue)
			} else if state.isColdFailure, let error = state.error {
				FailedView(error)
			} else if let project = state.value {
				Section {
					ProjectHeaderView(project) {
						await loader.reload(ProjectQuery(fullPath: fullPath))
					}
				}

				if project.archived == true {
					Section {
						Label("This project has been archived", systemImage: "archivebox.fill")
					}
				}

				if let lastCommit = project.repository?.tree?.lastCommit,
					let projectId = project.id.toIntId()
				{
					Section("Last commit") {
						SmallCommitView(lastCommit, projectId)
					}
				}

				Section("Actions") {
					if project.issuesEnabled ?? true {
						NavigationLink(
							destination: ProjectIssuesLoader(
								fullPath: self.fullPath
							),
							label: {
								Label(
									title: {
										HStack {
											Text("Issues")
											Spacer()
											Text("\(project.openIssuesCount ?? 0)")
										}
									},
									icon: {
										Image(systemName: Icons.issues.rawValue)
											.foregroundStyle(.green)
									})
							}
						)
					}

					if project.mergeRequestsEnabled ?? true {
						NavigationLink(
							destination: ProjectMergeLoader(fullPath: self.fullPath),
							label: {
								Label(
									title: {
										HStack {
											Text("Merge Requests")
											Spacer()
											Text(
												"\(project.openMergeRequestsCount ?? 0)"
											)
										}
									},
									icon: {
										Image(Images.mergeRequest.rawValue)
											.foregroundStyle(.blue)
									}
								)
							}
						)
					}

					if let projectId = project.id.toIntId() {
						DisclosureGroup(
							content: {
								NavigationLink(
									destination: EventsLoader(projectId: projectId),
									label: {
										Text("Activity")
									})
								NavigationLink(
									"Members",
									destination: MembersLoader(
										fullPath: self.fullPath,
										id: projectId,
										type: .project
									)
								)
								NavigationLink(
									destination: LabelsLoader(
										fullPath: self.fullPath,
										id: projectId,
										queryType: .project
									),
									label: {
										HStack {
											Text("Labels")
											if let count = project.labels?.count {
												Spacer()
												Text("\(count)")
											}
										}
									}
								)
								NavigationLink(
									"Milestones",
									destination: MilestonesLoader(
										fullPath: self.fullPath,
										id: projectId,
										queryType: .project
									)
								)
								NavigationLink(
									destination: EditProjectView(
										projectId: projectId,
										name: project.name,
										description: project.description,
										visibility: project.visibility ?? "private"
									),
									label: {
										Text("Settings")
									}
								)
							},
							label: {
								Label("Manage", systemImage: Icons.members.rawValue)
							}
						)
					}

					if let projectId = project.id.toIntId() {
						DisclosureGroup(
							content: {
								if let ref = project.repository?.rootRef {
									NavigationLink(
										"Repository",
										destination: TreeLoader(
											projectId: projectId,
											fullPath: self.fullPath,
											refName: ref
										)
									)

									NavigationLink(
										destination: CommitsLoader(projectId, refName: ref),
										label: {
											HStack {
												Text("Commits")
												if let commitCount = project.statistics?.commitCount {
													Spacer()
													Text("\(Int(commitCount))")
												}
											}
										})
								}

								NavigationLink(
									"Branches",
									destination: BranchesLoader(projectId)
								)

								NavigationLink(
									"Tags",
									destination: TagsLoader(projectId)
								)

								if project.wikiEnabled ?? true {
									NavigationLink(
										"Wiki",
										destination: WikisLoader(projectId: projectId)
									)
								}

								if project.snippetsEnabled ?? true {
									NavigationLink(
										"Snippets",
										destination: ProjectSnippetsLoader(
											fullPath: self.fullPath, projectId: projectId)
									)
								}
							},
							label: {
								Label(
									"Code",
									systemImage: Icons.code.rawValue
								)
							}
						)
					}

					DisclosureGroup(
						content: {
							NavigationLink(
								"Pipelines",
								destination: ProjectPipelinesLoader(fullPath: self.fullPath)
							)
							NavigationLink(
								destination: ProjectReleasesLoader(
									fullPath: self.fullPath, projectId: project.id.toIntId()),
								label: {
									HStack {
										Text("Releases")
										if let count = project.releases?.count {
											Spacer()
											Text("\(count)")
										}
									}
								}
							)
						},
						label: {
							Label("Build", systemImage: Icons.flag.rawValue)
						})
				}

				let files = [
					SpecialFile(
						name: "README", content: project.repository?.readme?.nodes?.first??.rawTextBlob?.emojized(),
						showsImages: true),
					SpecialFile(
						name: "LICENSE", content: project.repository?.license?.nodes?.first??.rawTextBlob?.emojized(),
						showsImages: false),
					SpecialFile(
						name: "CONTRIBUTING",
						content: project.repository?.contributing?.nodes?.first??.rawTextBlob?.emojized(),
						showsImages: true),
				].compactMap { $0 }

				let baseUrl = URL(string: project.webUrl ?? "")
				let imgUrl = URL(
					string:
						"\(project.webUrl ?? "")/-/raw/\(project.repository?.rootRef ?? "")/"
				)

				if !files.isEmpty {
					let selected = files[min(selectedFile, files.count - 1)]
					Section("Special files") {
						VStack {
							if files.count > 1 {
								Picker("", selection: $selectedFile) {
									ForEach(files.indices, id: \.self) { index in
										Text(files[index].name).tag(index)
									}
								}.pickerStyle(.segmented)
							}

							Markdown(
								selected.content,
								baseURL: baseUrl,
								imageBaseURL: selected.showsImages ? imgUrl : nil
							)
						}
					}
				}
			}
		}.task {
			await loader.load(ProjectQuery(fullPath: fullPath))
		}.refreshable {
			await loader.reload(ProjectQuery(fullPath: fullPath))
		}.toolbar {
			if let project = loader.state.value {
				HStack {
					Menu("More", systemImage: "ellipsis") {
						Section {
							if let webUrl = project.webUrl,
								let url = URL(string: webUrl)
							{
								ShareButton(url)
							}
						}

						if project.userPermissions.requestAccess,
							let projectId = project.id.toIntId()
						{
							Section {
								AsyncButton(
									"Request access",
									systemImage: "person.badge.plus"
								) {
									await requestAccess(projectId)
								}
							}
						}

						let showCloneSection =
							(project.httpUrlToRepo != nil
								|| project.sshUrlToRepo != nil)

						if showCloneSection {
							Section("Clone Code") {
								if let httpUrl = project.httpUrlToRepo {
									Button(
										"Copy HTTP url",
										systemImage: Icons.copy.rawValue
									) {
										httpUrl.copyToClipboard()
										Notify.status(
											.success, "Copied to clipboard",
											systemImage: "checkmark")
									}
								}

								if let sshUrl = project.sshUrlToRepo {
									Button(
										"Copy SSH url",
										systemImage: Icons.copy.rawValue
									) {
										sshUrl.copyToClipboard()
										Notify.status(
											.success, "Copied to clipboard",
											systemImage: "checkmark")
									}
								}
							}
						}

						if let projectId = project.id.toIntId() {
							Section {
								// ponytail: bare-repo + LFS size is an upper bound, not the zip size.
								let sizeLabel = [
									project.statistics?.repositorySize,
									project.statistics?.lfsObjectsSize,
								].compactMap { $0 }.reduce(0, +)
								AsyncButton(
									sizeLabel > 0
										? "Download archive (~\(ByteFormatter.shared.format(Int64(sizeLabel))))"
										: "Download archive",
									systemImage: Icons.archive.rawValue
								) {
									await downloadArchive(projectId, ref: project.repository?.rootRef)
								}
							}
						}
					}

					Menu("Create", systemImage: "plus") {
						if project.userPermissions.createIssue {
							Button("Create Issue", systemImage: Icons.issues.rawValue) {
								navigationActive = true
								navigationDestination = .issue
							}
						}

						Button("Create Milestone", systemImage: Icons.milestones.rawValue) {
							navigationActive = true
							navigationDestination = .milestone
						}

						if project.mergeRequestsEnabled ?? true {
							Button("Create Merge Request", systemImage: "arrow.triangle.branch") {
								navigationActive = true
								navigationDestination = .mergeRequest
							}
						}

						Button("Create Release", systemImage: Icons.flag.rawValue) {
							navigationActive = true
							navigationDestination = .release
						}

						if (project.snippetsEnabled ?? true) && project.userPermissions.createSnippet {
							Button("Create Snippet", systemImage: Icons.snippets.rawValue) {
								navigationActive = true
								navigationDestination = .snippet
							}
						}

						Button("Add new Member", systemImage: "person.badge.plus") {
							navigationActive = true
							navigationDestination = .member
						}

						Button("Share with Group", systemImage: "person.2.badge.plus") {
							navigationActive = true
							navigationDestination = .groupShare
						}

						Button("Create Label", systemImage: Icons.tag.rawValue) {
							navigationActive = true
							navigationDestination = .label
						}
					}
				}
			}
		}.navigationDestination(isPresented: $navigationActive) {
			if let project = loader.state.value,
				let projectId = project.id.toIntId(),
				let navigationDestination
			{
				switch navigationDestination {
				case .issue:
					NewIssueView(id: projectId, fullPath: self.fullPath)
				case .mergeRequest:
					NewMergeRequestView(id: projectId, targetBranch: project.repository?.rootRef ?? "main")
				case .milestone:
					NewMilestoneView(id: projectId, groupId: 0)
				case .release:
					NewReleaseView(id: projectId, fullPath: self.fullPath)
				case .member:
					NewMemberView(id: projectId, groupId: 0)
				case .groupShare:
					NewGroupShareView(id: projectId)
				case .label:
					NewLabelView(id: projectId, groupId: 0)
				case .snippet:
					NewSnippetView(projectId: projectId)
				}
			}
		}
		.navigationTitle(self.fullPath)
		.navigationBarTitleDisplayMode(.inline)
	}
}

#Preview {
	NavigationStack {
		ProjectLoader(fullPath: "felix-schindler/gitlab-ios")
	}
}
