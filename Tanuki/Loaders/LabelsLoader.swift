//
//  GroupLabelsLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 07.03.24.
//

import GitLabAPI
import SwiftUI

enum LabelQueryType {
	case group,
		project
}

struct LabelsLoader: View {
	private let id: Int
	private let fullPath: String
	private let queryType: LabelQueryType

	@State
	private var labels: Result<[MyLabel?], Error>? = nil

	init(fullPath: String, id: Int, queryType: LabelQueryType) {
		self.fullPath = fullPath
		self.id = id
		self.queryType = queryType
	}

	private func loadLabels() {
		do {
			switch self.queryType {
			case .group:
				let responses = try Network.shared.apollo.fetch(
					query: GroupLabelsQuery(fullPath: self.fullPath), cachePolicy: .cacheAndNetwork)

				Task {
					for try await response in responses {
						if let labels = response.data?.group?.labels?.nodes {
							self.labels = .success(labels)
						} else if let errors = response.errors {
							for error in errors {
								Notify.status(.error, error.localizedDescription)
							}
						}
					}
				}
			case .project:
				let responses = try Network.shared.apollo.fetch(
					query: ProjectLabelsQuery(fullPath: self.fullPath),
					cachePolicy: .cacheAndNetwork)

				Task {
					for try await response in responses {
						if let labels = response.data?.project?.labels?.nodes {
							self.labels = .success(labels)
						} else if let errors = response.errors {
							for error in errors {
								Notify.status(.error, error.localizedDescription)
							}
						}
					}
				}
			}
		} catch let error {
			self.labels = .failure(error)
			Notify.status(.error)
		}
	}

	private func reloadLabels() async {
		do {
			switch self.queryType {
			case .group:
				let response = try await Network.shared.apollo.fetch(
					query: GroupLabelsQuery(fullPath: self.fullPath), cachePolicy: .networkOnly)

				if let labels = response.data?.group?.labels?.nodes {
					self.labels = .success(labels)
				}

				Notify.status(.success)
			case .project:
				let response = try await Network.shared.apollo.fetch(
					query: ProjectLabelsQuery(fullPath: self.fullPath), cachePolicy: .networkOnly)

				if let labels = response.data?.project?.labels?.nodes {
					self.labels = .success(labels)
				}

				Notify.status(.success)
			}
		} catch let error {
			self.labels = .failure(error)
			Notify.status(.error)
		}
	}

	public var body: some View {
		List {
			if let labels {
				switch labels {
				case .success(let labels):
					if labels.isEmpty {
						NoContentView("There are no labels", systemImage: "tag")
					} else {
						ForEach(labels, id: \.?.id) { maybeLabel in
							if let label = maybeLabel {
								VStack(alignment: .leading) {
									ScrollView(.horizontal) {
										PillView(
											label.title.emojized(),
											bgColor: Color(hex: label.color),
											fgColor: Color(hex: label.textColor)
										)
									}

									if let description = label.description, description.isNotEmpty {
										Markdown(description)
									}
								}
							}
						}
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading Labels", systemImage: "tag")
			}
		}.task {
			loadLabels()
		}.refreshable {
			await reloadLabels()
		}.toolbar {
			if let labels, case .success = labels {
				NavigationLink(
					destination: {
						if self.queryType == .project {
							NewLabelView(id: self.id, groupId: 0)
						} else {
							NewLabelView(id: 0, groupId: self.id)
						}
					},
					label: {
						Label("New label", systemImage: "plus")
					}
				).tint(.accentColor)
			}
		}.navigationTitle("Labels")
	}
}

#Preview {
	NavigationStack {
		LabelsLoader(fullPath: "gitlab-org", id: 278_964, queryType: .group)
	}
}
