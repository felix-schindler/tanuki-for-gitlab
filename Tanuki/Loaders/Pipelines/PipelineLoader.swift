//
//  PipelineLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 08.10.26.
//

import GitLabAPI
import SwiftUI
import TanukiShared

struct PipelineLoader: View {
	private let fullPath: String
	private let iid: String

	@State
	private var loader = ApolloLoader<PipelineDetailQuery, PipelineDetailQuery.Data.Project.Pipeline> {
		$0.project?.pipeline
	}

	init(fullPath: String, iid: String) {
		self.fullPath = fullPath
		self.iid = iid
	}

	var body: some View {
		let state = loader.state

		List {
			if state.isInitialLoading {
				LoadingView("Loading pipeline", systemImage: Icons.flag.rawValue)
			} else if state.isColdFailure, let error = state.error {
				FailedView(error)
			} else if let pipeline = state.value {
				Section {
					PipelineHeaderView(fullPath: fullPath, pipeline: pipeline) {
						await loader.reload(PipelineDetailQuery(fullPath: fullPath, iid: iid))
					}
				}

				Section("Jobs") {
					let stages = pipeline.stages?.nodes?.compactMap { $0 } ?? []
					if stages.isEmpty {
						NoContentView("No jobs", systemImage: Icons.flag.rawValue)
					} else {
						ForEach(stages, id: \.name) { stage in
							let jobs = stage.jobs?.nodes?.compactMap { $0 } ?? []
							if jobs.isNotEmpty {
								Section(stage.name?.capitalized ?? "Stage") {
									ForEach(jobs, id: \.id) { job in
										PipelineJobView(fullPath: fullPath, job: job) {
											await loader.reload(PipelineDetailQuery(fullPath: fullPath, iid: iid))
										}
									}
								}
							}
						}
					}
				}
			}

		}.task {
			await loader.load(PipelineDetailQuery(fullPath: fullPath, iid: iid))
		}.refreshable {
			await loader.reload(PipelineDetailQuery(fullPath: fullPath, iid: iid))
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
