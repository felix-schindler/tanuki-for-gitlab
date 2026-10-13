//
//  LoadingView.swift
//  Tanuki
//
//  Created by Felix Schindler on 21.09.25.
//

import LucideSwift
import SwiftUI

struct LoadingView: View {
	private let msg: String
	private let icon: LucideIconName
	private let color: Color

	init(_ message: String, lucide: LucideIconName, color: Color = .secondary) {
		self.msg = message
		self.icon = lucide
		self.color = color
	}

	var body: some View {
		VStack {
			ProgressView(label: {
				Label(msg, lucide: icon, color: color)
			})
		}.frame(maxWidth: .infinity, minHeight: 100)
	}
}

#Preview {
	List {
		LoadingView("Loading Project", lucide: .layers)
		LoadingView("Loading MR", lucide: .gitPullRequest)
	}
}
