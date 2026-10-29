//
//  PipelineStatus.swift
//  Tanuki
//
//  Created by Felix Schindler on 26.02.24.
//

import GitLabAPI
import Lucide
import SwiftUI

struct PipelineStatus: View {
	private let state: GraphQLEnum<GitLabAPI.PipelineStatusEnum>
	private let icon: LucideIcon
	private let color: SwiftUI.Color

	@State
	private var showInfo = false

	init(_ state: GraphQLEnum<GitLabAPI.PipelineStatusEnum>) {
		self.state = state

		let style = Self.style(for: state)
		self.icon = style.icon
		self.color = style.color
	}

	/// REST APIs return lowercase statuses (`"running"`); GraphQL uses uppercase enum cases.
	init(_ status: String) {
		self.init(GraphQLEnum<GitLabAPI.PipelineStatusEnum>(rawValue: status.uppercased()))
	}

	/// Shared icon/color mapping so list rows and pills can reuse it without the button.
	static func style(for state: GraphQLEnum<GitLabAPI.PipelineStatusEnum>) -> (
		icon: LucideIcon, color: SwiftUI.Color
	) {
		switch state {
		case .created:
			(.circlePlus, .orange)
		case .waitingForResource, .waitingForCallback:
			(.circlePause, .orange)
		case .success:
			(.circleCheck, .green)
		case .failed:
			(.circleMinus, .red)
		case .canceled:
			(.circleSlash, .gray)
		case .skipped:
			(.circleChevronRight, .gray)
		case .manual:
			(.circleUserRound, .primary)
		case .scheduled:
			(.hourglass, .primary)
		default:
			(.refreshCw, .orange)
		}
	}

	/// `"WAITING_FOR_RESOURCE"` → `"Waiting For Resource"`.
	static func label(for rawValue: String) -> String {
		rawValue.split(separator: "_").joined(separator: " ").lowercased().capitalized
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
