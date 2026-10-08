//
//  PipelineStatus.swift
//  Tanuki
//
//  Created by Felix Schindler on 26.02.24.
//

import GitLabAPI
import SwiftUI

struct PipelineStatus: View {
	private let state: GraphQLEnum<GitLabAPI.PipelineStatusEnum>
	private let icon: String
	private let color: SwiftUI.Color

	@State
	private var showInfo = false

	init(_ state: GraphQLEnum<GitLabAPI.PipelineStatusEnum>) {
		self.state = state

		switch state {
		case .created:
			self.icon = "plus.circle"
			self.color = Color.orange
		case .waitingForResource, .waitingForCallback:
			self.icon = "pause.circle"
			self.color = Color.orange
		case .success:
			self.icon = "checkmark.circle"
			self.color = Color.green
		case .failed:
			self.icon = "minus.circle"
			self.color = Color.red
		case .canceled:
			self.icon = "slash.circle"
			self.color = Color.gray
		case .skipped:
			self.icon = "chevron.right.circle"
			self.color = Color.gray
		case .manual:
			self.icon = "person.crop.circle"
			self.color = Color.primary
		case .scheduled:
			self.icon = "hourglass.circle"
			self.color = Color.primary
		default:
			self.icon = "arrow.2.circlepath.circle"
			self.color = Color.orange
		}
	}

	/// REST APIs return lowercase statuses (`"running"`); GraphQL uses uppercase enum cases.
	init(_ status: String) {
		self.init(GraphQLEnum<GitLabAPI.PipelineStatusEnum>(rawValue: status.uppercased()))
	}

	public var body: some View {
		VStack {
			RoundIconButton("Pipeline status", icon: icon) {
				Haptics.shared.play(.light)
				showInfo = true
			}
			.tint(self.color)
			.controlSize(.mini)
		}.sheet(isPresented: $showInfo) {
			VStack(alignment: .leading) {
				PopupHeader(
					title: "Pipeline status",
					onClose: {
						showInfo = false
					})
				Text("The current Pipeline status is \"\(state.rawValue)\"")
				Spacer()
			}
			.padding()
			.presentationDetents([.fraction(0.2), .medium])
		}
	}
}

#Preview {
	VStack {
		ForEach(GraphQLEnum<GitLabAPI.PipelineStatusEnum>.allCases, id: \.self) { state in
			PipelineStatus(state)
		}
	}
}
