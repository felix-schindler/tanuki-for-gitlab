//
//  SmallPipelineView.swift
//  Tanuki
//
//  Created by Felix Schindler on 08.10.26.
//

import GitLabAPI
import SwiftUI

struct SmallPipelineView: View {
	private let pipeline: ProjectPipelinesQuery.Data.Project.Pipelines.Node

	init(_ pipeline: ProjectPipelinesQuery.Data.Project.Pipelines.Node) {
		self.pipeline = pipeline
	}

	var body: some View {
		let style = PipelineStatus.style(for: pipeline.status)
		return Label {
			VStack(alignment: .leading) {
				HStack {
					Text(pipeline.name ?? "#\(pipeline.iid)")
						.font(.subheadline)
						.fontWeight(.medium)
						.lineLimit(1)
					if pipeline.name != nil {
						Text("#\(pipeline.iid)")
							.font(.footnote)
							.foregroundStyle(.secondary)
							.monospacedDigit()
					}
					if let ref = pipeline.ref {
						Text(ref)
							.font(.subheadline)
							.foregroundStyle(.secondary)
							.lineLimit(1)
					}
				}

				ScrollView(.horizontal) {
					HStack {
						if let author = pipeline._author {
							AuthorView(author)
						}
						if let commitId = pipeline.commit?.shortId {
							PillView(commitId, icon: "text.line.first.and.arrowtriangle.forward")
								.textSelection(.enabled)
								.font(.system(.footnote, design: .monospaced))
						}
						if let source = pipeline.source {
							PillView(source)
						}
						Spacer()
						Text(Date.fromToString(pipeline.createdAt, timeStyle: .short))
							.font(.caption2)
							.foregroundStyle(.secondary)
					}.font(.footnote)
				}
			}
		} icon: {
			Image(systemName: style.icon)
				.foregroundStyle(style.color)
		}
	}
}
