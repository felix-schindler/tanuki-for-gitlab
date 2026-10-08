//
//  PipelineLoader.swift
//  Tanuki
//
//  Pipeline detail (header, jobs grouped by stage, log, retry/cancel/play).
//  Reads via GraphQL; job trace, artifact download and trigger actions use
//  REST, which GraphQL does not expose (trace) or which need no new schema
//  types (fire-and-forget POSTs).
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

	private func pipelineAction(_ action: String) async {
		do {
			_ = try await API.raw(
				method: .post,
				endpoint: "projects", resource: fullPath, suffix: "pipelines/\(iid)/\(action)")
			Notify.status(.success, "Pipeline \(action)ed", systemImage: "checkmark")
			await reloadPipeline()
		} catch {
			Notify.status(.error, "Action failed", error.localizedDescription, systemImage: "xmark")
		}
	}

	var body: some View {
		List {
			if let pipeline {
				switch pipeline {
				case .success(let pipeline):
					Section {
						VStack(alignment: .leading, spacing: 12) {
							HStack {
								PillView(
									pipeline.status.rawValue.capitalized,
									bgColor: .secondary.opacity(0.2))
								Spacer()
								Text("#\(pipeline.iid)")
									.font(.footnote)
									.foregroundStyle(.secondary)
									.monospacedDigit()
							}

							if let name = pipeline.name, name.isNotEmpty {
								Text(name)
									.font(.title3)
									.fontWeight(.medium)
							}

							ScrollView(.horizontal) {
								HStack {
									if let author = pipeline._author {
										AuthorView(author)
									}
									if let ref = pipeline.ref {
										PillView(ref)
									}
									if let sha = pipeline.sha {
										PillView(String(sha.prefix(7)))
											.monospaced()
									}
									if let source = pipeline.source {
										PillView(source)
									}
								}
							}.font(.footnote)

							Divider()

							LabeledContent(
								"Created",
								value: Date.fromToString(pipeline.createdAt, timeStyle: .short))
							if let startedAt = pipeline.startedAt {
								LabeledContent(
									"Started", value: Date.fromToString(startedAt, timeStyle: .short))
							}
							if let finishedAt = pipeline.finishedAt {
								LabeledContent(
									"Finished", value: Date.fromToString(finishedAt, timeStyle: .short))
							}
							if let duration = durationString(pipeline.duration) {
								LabeledContent("Duration", value: duration)
							}
						}
					}

					Section {
						HStack {
							AsyncButton("Retry", systemImage: "arrow.clockwise") {
								await pipelineAction("retry")
							}
							Spacer()
							AsyncButton("Cancel", systemImage: "xmark") {
								await pipelineAction("cancel")
							}
						}.buttonStyle(.bordered)
					}

					Section("Jobs") {
						let stages = pipeline.stages?.nodes?.compactMap { $0 } ?? []
						if stages.isEmpty {
							NoContentView("No jobs", systemImage: "flag")
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
				LoadingView("Loading pipeline", systemImage: "flag")
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

/// Formats seconds, `nil` in → `nil` out so callers can hide the row.
func durationString(_ seconds: Int?) -> String? {
	guard let seconds, seconds >= 0 else { return nil }
	let formatter = DateComponentsFormatter()
	formatter.allowedUnits = [.hour, .minute, .second]
	formatter.unitsStyle = .abbreviated
	return formatter.string(from: Double(seconds))
}

struct PipelineJobView: View {
	let fullPath: String
	let job: PipelineJob
	var onAction: () async -> Void

	@State
	private var artifactURL: URL? = nil

	private var jobId: Int? {
		job.id?.toIntId()
	}

	private var statusName: String {
		job.status?.rawValue ?? "UNKNOWN"
	}

	private func jobAction(_ action: String) async {
		guard let jobId else { return }
		do {
			_ = try await API.raw(
				method: .post,
				endpoint: "projects", resource: fullPath, suffix: "jobs/\(jobId)/\(action)")
			Notify.status(.success, "Job \(action)ed", systemImage: "checkmark")
			await onAction()
		} catch {
			Notify.status(.error, "Action failed", error.localizedDescription, systemImage: "xmark")
		}
	}

	private func downloadArtifacts() async {
		guard let jobId else { return }
		do {
			let url = try await API.download(
				to: { _, _ in
					(
						FileCache.destination(for: "job-\(jobId)-artifacts.zip"),
						[.createIntermediateDirectories, .removePreviousFile]
					)
				},
				method: .get,
				endpoint: "projects", resource: fullPath, suffix: "jobs/\(jobId)/artifacts"
			)
			FileCache.purge()
			artifactURL = url
			Notify.status(.success, "Artifacts downloaded", systemImage: "checkmark")
		} catch {
			Notify.status(.error, "Download failed", error.localizedDescription, systemImage: "xmark")
		}
	}

	var body: some View {
		DisclosureGroup {
			if let failureMessage = job.failureMessage, failureMessage.isNotEmpty {
				Text(failureMessage)
					.font(.footnote)
					.foregroundStyle(.red)
			}

			LabeledContent("Status", value: statusName.capitalized)
			LabeledContent("Duration", value: durationString(job.duration) ?? "--")
			if let startedAt = job.startedAt {
				LabeledContent("Started", value: Date.fromToString(startedAt, timeStyle: .short))
			}
			if job.allowFailure {
				LabeledContent("Allowed to fail", value: "Yes")
			}
			let artifacts = job.artifacts?.nodes?.compactMap { $0 } ?? []
			if artifacts.isNotEmpty {
				LabeledContent("Artifacts", value: "\(artifacts.count)")
			}

			if let jobId {
				NavigationLink(destination: JobTraceView(fullPath: fullPath, jobId: jobId, jobName: job.name ?? "Job"))
				{
					Label("Log", systemImage: "doc.text")
				}
			}

			HStack {
				AsyncButton("Retry", systemImage: "arrow.clockwise") {
					await jobAction("retry")
				}
				Spacer()
				if statusName == "MANUAL" {
					AsyncButton("Play", systemImage: "play") {
						await jobAction("play")
					}
					Spacer()
				}
				if let artifactURL {
					ShareButton(artifactURL)
					Spacer()
				} else if artifacts.isNotEmpty {
					AsyncButton(systemImage: "square.and.arrow.down") {
						await downloadArtifacts()
					}
					Spacer()
				}
				AsyncButton("Cancel", systemImage: "xmark") {
					await jobAction("cancel")
				}
			}.buttonStyle(.bordered)
				.controlSize(.small)
		} label: {
			HStack {
				PipelineStatus(statusName)
				Text(job.name ?? "Job")
					.fontWeight(.medium)
				Spacer()
				Text(durationString(job.duration) ?? "--")
					.font(.footnote)
					.foregroundStyle(.secondary)
					.monospacedDigit()
			}
		}
	}
}

struct JobTraceView: View {
	let fullPath: String
	let jobId: Int
	let jobName: String

	@State
	private var trace: Result<String, Error>? = nil

	private func loadTrace() async {
		do {
			let response = try await API.raw(
				method: .get,
				endpoint: "projects", resource: fullPath, suffix: "jobs/\(jobId)/trace")
			guard let data = response.data, let text = String(data: data, encoding: .utf8) else {
				throw APIError.emptyResponse
			}
			trace = .success(text)
		} catch {
			trace = .failure(error)
			Notify.status(.error)
		}
	}

	var body: some View {
		ScrollView {
			if let trace {
				switch trace {
				case .success(let text):
					if text.isEmpty {
						NoContentView("No log output", systemImage: "doc.text")
					} else {
						Text(text)
							.font(.system(.caption, design: .monospaced))
							.textSelection(.enabled)
							.frame(maxWidth: .infinity, alignment: .leading)
							.padding(.horizontal)
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading log", systemImage: "doc.text")
			}
		}.task {
			await loadTrace()
		}.refreshable {
			await loadTrace()
		}.toolbar {
			if case .success(let text) = trace, text.isNotEmpty {
				Button("Copy log", systemImage: "doc.on.doc") {
					text.copyToClipboard()
					Notify.status(.success, "Copied to clipboard", systemImage: "checkmark")
				}
			}
		}.navigationTitle(jobName)
			.navigationBarTitleDisplayMode(.inline)
	}
}

#Preview {
	NavigationStack {
		PipelineLoader(fullPath: "felix-schindler/gitlab-ios", iid: "1")
	}
}
