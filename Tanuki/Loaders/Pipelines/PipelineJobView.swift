//
//  PipelineJobView.swift
//  Tanuki
//
//  Created by Felix Schindler on 08.10.26.
//

import GitLabAPI
import SwiftUI

struct PipelineJobView: View {
	let fullPath: String
	let job: PipelineJob
	var onAction: () async -> Void

	@State
	private var downloadingArtifactId: String? = nil

	@State
	private var showDownloadError = false

	@State
	private var downloadError: Error? = nil

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

	private func downloadArtifacts(id: String) async {
		guard let jobId, downloadingArtifactId == nil else { return }
		downloadingArtifactId = id
		defer { downloadingArtifactId = nil }
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
			Notify.status(.success, "Artifacts downloaded", systemImage: "checkmark")
			ShareSheet.present(for: url)
		} catch {
			downloadError = error
			showDownloadError = true
		}
	}

	var body: some View {
		DisclosureGroup {
			let artifacts = job.artifacts?.nodes?.compactMap { $0 } ?? []

			VStack(alignment: .leading) {
				if let failureMessage = job.failureMessage, failureMessage.isNotEmpty {
					Text(failureMessage)
						.font(.footnote)
						.foregroundStyle(.red)
				}

				ScrollView(.horizontal) {
					HStack {
						if let duration = durationString(job.duration) {
							PillView(duration)
						}
						if let startedAt = job.startedAt {
							PillView(Date.fromToString(startedAt, timeStyle: .short))
						}
						if job.allowFailure {
							PillView("Allowed to fail")
						}
					}
				}.font(.footnote)

				ScrollView(.horizontal) {
					HStack {
						if let jobId {
							NavigationLink(
								destination: JobTraceView(
									fullPath: fullPath, jobId: jobId, jobName: job.name ?? "Job")
							) {
								Label("Log", lucide: .fileText)
							}
						}
						if job.retryable {
							AsyncButton("Retry", lucide: .rotateCw) {
								await jobAction("retry")
							}
						}
						if job.playable {
							AsyncButton("Play", lucide: .play) {
								await jobAction("play")
							}
						}
						if job.cancelable {
							AsyncButton("Cancel", lucide: .x) {
								await jobAction("cancel")
							}
						}
					}
					.adaptiveButtonStyle()
					.controlSize(.small)
				}
			}

			if artifacts.isNotEmpty {
				DisclosureGroup("Artifacts (\(artifacts.count))") {
					ForEach(artifacts, id: \.id) { artifact in
						HStack {
							if downloadingArtifactId == artifact.id {
								ProgressView()
									.controlSize(.small)
							} else {
								LucideLabelIcon(.download)
							}
							Text(
								"\(artifact.name ?? "") (\(ByteFormatter.shared.format(Int64(artifact.size) ?? 0)))"
							)
							Spacer()
						}
						.contentShape(Rectangle())
						.onTapGesture {
							Task {
								await downloadArtifacts(id: artifact.id)
							}
						}
					}
				}
				.alert(
					"Download failed", isPresented: $showDownloadError,
					actions: {
						Button("OK") { downloadError = nil }
					},
					message: {
						Text(downloadError?.localizedDescription ?? "")
					}
				)
			}
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
