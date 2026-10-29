//
//  ProjectPipelinesLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 07.03.24.
//

import GitLabAPI
import SwiftUI

struct ProjectPipelinesLoader: View {
	private var fullPath: String

	@State
	private var pipelines: Result<[ProjectPipelinesQuery.Data.Project.Pipelines.Node?], Error>? =
		nil

	init(fullPath: String) {
		self.fullPath = fullPath
	}

	private func loadPipelines() {
		do {
			let responses = try Network.shared.apollo.fetch(
				query: ProjectPipelinesQuery(fullPath: self.fullPath), cachePolicy: .cacheAndNetwork
			)

			Task {
				for try await response in responses {
					if let pipelines = response.data?.project?.pipelines?.nodes {
						self.pipelines = .success(pipelines)
					} else if let errors = response.errors {
						for error in errors {
							Notify.status(.error, error.localizedDescription)
						}
					}
				}
			}
		} catch let error {
			self.pipelines = .failure(error)
			Notify.status(.error)
		}
	}

	private func reloadPipelines() async {
		do {
			let response = try await Network.shared.apollo.fetch(
				query: ProjectPipelinesQuery(fullPath: self.fullPath), cachePolicy: .networkOnly)

			if let pipelines = response.data?.project?.pipelines?.nodes {
				self.pipelines = .success(pipelines)
			}

			Notify.status(.success)
		} catch let error {
			self.pipelines = .failure(error)
			Notify.status(.error)
		}
	}

	public var body: some View {
		List {
			if let pipelines {
				switch pipelines {
				case .success(let pipelines):
					if pipelines.isEmpty {
						NoContentView("There are no pipelines", systemImage: "flag")
					} else {
						ForEach(pipelines, id: \.?.id) { maybePipeline in
							if let pipeline = maybePipeline {
								NavigationLink(
									destination: PipelineLoader(
										fullPath: self.fullPath, iid: pipeline.iid
									)
								) {
									SmallPipelineView(pipeline)
								}
							}
						}
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading Pipelines", systemImage: "flag")
			}
		}.task {
			loadPipelines()
		}.refreshable {
			await reloadPipelines()
		}.navigationTitle("Pipelines")
	}
}

#Preview {
	NavigationStack {
		ProjectPipelinesLoader(fullPath: "felix-schindler/gitlab-ios")
	}
}
