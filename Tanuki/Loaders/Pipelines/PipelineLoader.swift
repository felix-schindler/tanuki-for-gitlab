//
//  PipelineLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 08.10.26.
//

import GitLabAPI
import SwiftUI

struct PipelineLoader: View {
	private let fullPath: String
	private let iid: String

	@State
	private var pipeline: Result<PipelineDetailQuery.Data.Project.Pipeline, Error>? = nil

	init(fullPath: String, iid: String) {
		self.fullPath = fullPath
		self.iid = iid
	}

	private func loadPipeline() {
		do {
			let responses = try Network.shared.apollo.fetch(
				query: PipelineDetailQuery(fullPath: self.fullPath, iid: self.iid),
				cachePolicy: .cacheAndNetwork
			)

			Task {
				for try await response in responses {
					if let pipeline = response.data?.project?.pipeline {
						self.pipeline = .success(pipeline)
					} else if let errors = response.errors {
						for error in errors {
							Notify.status(.error, error.localizedDescription)
						}
					}
				}
			}
		} catch let error {
			self.pipeline = .failure(error)
			Notify.status(.error)
		}
	}

	private func reloadPipeline() async {
		do {
			let response = try await Network.shared.apollo.fetch(
				query: PipelineDetailQuery(fullPath: self.fullPath, iid: self.iid),
				cachePolicy: .networkOnly)

			if let pipeline = response.data?.project?.pipeline {
				self.pipeline = .success(pipeline)
				Notify.status(.success)
			} else {
				Notify.status(.error)
			}
		} catch let error {
			self.pipeline = .failure(error)
			Notify.status(.error)
		}
	}

	var body: some View {
		List {
			if let pipeline {
				switch pipeline {
				case .success(let pipeline):
					Section {
						PipelineHeaderView(fullPath: fullPath, pipeline: pipeline) {
							await reloadPipeline()
						}
					}

					Section("Jobs") {
						let stages = pipeline.stages?.nodes?.compactMap { $0 } ?? []
						if stages.isEmpty {
							NoContentView("No jobs", lucide: .workflow)
						} else {
							ForEach(stages, id: \.name) { stage in
								let jobs = stage.jobs?.nodes?.compactMap { $0 } ?? []
								if jobs.isNotEmpty {
									Section(stage.name?.capitalized ?? "Stage") {
										ForEach(jobs, id: \.id) { job in
											PipelineJobView(fullPath: fullPath, job: job) {
												await reloadPipeline()
											}
										}
									}
								}
							}
						}
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading pipeline", lucide: .workflow)
			}
		}.task {
			loadPipeline()
		}.refreshable {
			await reloadPipeline()
		}.navigationTitle("Pipeline #\(iid)")
			.navigationBarTitleDisplayMode(.inline)
	}
}

typealias PipelineStage = PipelineDetailQuery.Data.Project.Pipeline.Stages.Node
typealias PipelineJob = PipelineDetailQuery.Data.Project.Pipeline.Stages.Node.Jobs.Node

#Preview {
	NavigationStack {
		PipelineLoader(fullPath: "felix-schindler/gitlab-ios", iid: "1")
	}
}
