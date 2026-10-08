//
//  TimelogsLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 07.03.24.
//

import GitLabAPI
import SwiftUI

enum TimelogsQueryType {
	case group,
		user
}

struct TimelogsLoader: View {
	private let fullPath: String
	private let queryType: TimelogsQueryType

	@State
	private var timelogs: Result<[Timelog?], Error>? = nil

	init(fullPath: String, queryType: TimelogsQueryType) {
		self.fullPath = fullPath
		self.queryType = queryType
	}

	private func loadTimelogs() {
		do {
			switch self.queryType {
			case .group:
				let responses = try Network.shared.apollo.fetch(
					query: GroupTimelogsQuery(fullPath: self.fullPath),
					cachePolicy: .cacheAndNetwork)

				Task {
					for try await response in responses {
						if let timelogs = response.data?.group?.timelogs.nodes {
							self.timelogs = .success(timelogs)
						} else if let errors = response.errors {
							for error in errors {
								Notify.status(.error, error.localizedDescription)
							}
						}
					}
				}
				break
			case .user:
				let responses = try Network.shared.apollo.fetch(
					query: UserTimelogsQuery(username: self.fullPath), cachePolicy: .cacheAndNetwork
				)

				Task {
					for try await response in responses {
						if let timelogs = response.data?.user?.timelogs?.nodes {
							self.timelogs = .success(timelogs)
						} else if let errors = response.errors {
							for error in errors {
								Notify.status(.error, error.localizedDescription)
							}
						}
					}
				}
				break
			}
		} catch let error {
			self.timelogs = .failure(error)
			Notify.status(.error)
		}
	}

	private func reloadTimelogs() async {
		do {
			switch self.queryType {
			case .group:
				let response = try await Network.shared.apollo.fetch(
					query: GroupTimelogsQuery(fullPath: self.fullPath), cachePolicy: .networkOnly)

				if let timelogs = response.data?.group?.timelogs.nodes {
					self.timelogs = .success(timelogs)
				}

				break
			case .user:
				let response = try await Network.shared.apollo.fetch(
					query: UserTimelogsQuery(username: self.fullPath), cachePolicy: .networkOnly)

				if let timelogs = response.data?.user?.timelogs?.nodes {
					self.timelogs = .success(timelogs)
				}

				break
			}

			Notify.status(.success)
		} catch let error {
			self.timelogs = .failure(error)
			Notify.status(.error)
		}
	}

	public var body: some View {
		List {
			if let timelogs {
				switch timelogs {
				case .success(let timelogs):
					if timelogs.isEmpty {
						NoContentView("There are no timelogs", systemImage: "hourglass")
					} else {
						ForEach(timelogs, id: \.?.id) { maybeLog in
							if let log = maybeLog {
								VStack(alignment: .leading) {
									HStack {
										ScrollView(.horizontal) {
											NavigationLink(
												destination: ProjectLoader(
													fullPath: log._project.fullPath
												),
												label: {
													Text(log._project.nameWithNamespace)
												}
											).foregroundStyle(.secondary)
										}

										if let spentAt = log.spentAt {
											Spacer()
											Text(Date.fromToString(spentAt))
										}
									}.font(.footnote)

									ScrollView(.horizontal) {
										HStack {
											AuthorView(log._user)

											if let issueIid = log._issue?.iid {
												NavigationLink(
													destination: IssueLoader(
														fullPath: log._project.fullPath,
														iid: issueIid
													),
													label: {
														PillView(
															"#\(issueIid)",
															icon: "smallcircle.circle",
															bgColor: .green,
															fgColor: .white,
															cornerRadius: 5
														)
													})
											}

											if let mergeIid = log._mergeRequest?.iid {
												NavigationLink(
													destination: MergeRequestLoader(
														fullPath: log._project.fullPath,
														iid: mergeIid
													),
													label: {
														PillView(
															"!\(mergeIid)",
															icon: "arrow.triangle.pull",
															bgColor: .blue,
															fgColor: .white,
															cornerRadius: 5
														)
													})
											}
										}.font(.footnote)
									}

									Text("\(log.timeSpent / 60) minutes")

									if let summary = log.summary, summary.isNotEmpty {
										Markdown(summary)
									}
								}
							}
						}
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading Timelogs", systemImage: "hourglass")
			}
		}.task {
			loadTimelogs()
		}.refreshable {
			await reloadTimelogs()
		}.navigationTitle("Timelogs")
	}
}

#Preview {
	NavigationStack {
		TimelogsLoader(fullPath: "felix-schindler", queryType: .user)
	}
}
