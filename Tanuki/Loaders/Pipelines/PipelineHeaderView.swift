//
//  PipelineHeaderView.swift
//  Tanuki
//
//  Created by Felix Schindler on 08.10.26.
//

import GitLabAPI
import SwiftUI

struct PipelineHeaderView: View {
	private let fullPath: String
	private let pipeline: PipelineDetailQuery.Data.Project.Pipeline
	private let onAction: () async -> Void

	init(
		fullPath: String,
		pipeline: PipelineDetailQuery.Data.Project.Pipeline,
		onAction: @escaping () async -> Void
	) {
		self.fullPath = fullPath
		self.pipeline = pipeline
		self.onAction = onAction
	}

	private func pipelineAction(_ action: String) async {
		do {
			_ = try await API.raw(
				method: .post,
				endpoint: "projects", resource: fullPath, suffix: "pipelines/\(pipeline.iid)/\(action)")
			Notify.status(.success, "Pipeline \(action)ed", systemImage: "checkmark")
			await onAction()
		} catch {
			Notify.status(.error, "Action failed", error.localizedDescription, systemImage: "xmark")
		}
	}

	var body: some View {
		let style = PipelineStatus.style(for: pipeline.status)
		return VStack(alignment: .leading, spacing: 12) {
			HStack {
				PillView(
					PipelineStatus.label(for: pipeline.status.rawValue),
					icon: style.icon,
					bgColor: style.color.opacity(0.2),
					fgColor: style.color)
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

			if pipeline.retryable || pipeline.cancelable {
				ScrollView(.horizontal) {
					HStack {
						if pipeline.retryable {
							AsyncButton("Retry", lucide: .rotateCw) {
								await pipelineAction("retry")
							}
						}
						if pipeline.cancelable {
							AsyncButton("Cancel", lucide: .x) {
								await pipelineAction("cancel")
							}
						}
					}
					.tint(.primary)
					.buttonStyle(.bordered)
					.controlSize(.small)
				}
			}
		}
	}
}

/// Formats seconds, `nil` in → `nil` out so callers can hide the row.
func durationString(_ seconds: Int?) -> String? {
	guard let seconds, seconds >= 0 else { return nil }
	let formatter = DateComponentsFormatter()
	formatter.allowedUnits = [.hour, .minute, .second]
	formatter.unitsStyle = .abbreviated
	return formatter.string(from: Double(seconds))
}
