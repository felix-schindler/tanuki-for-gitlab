//
//  LoadingView.swift
//  Tanuki
//
//  Created by Felix Schindler on 21.09.25.
//

import SwiftUI

struct LoadingView: View {
	private let msg: String
	private let icon: Image
	private let color: Color

	init(_ message: String, systemImage: String, color: Color = .secondary) {
		self.msg = message
		self.icon = Image(systemName: systemImage)
		self.color = color
	}

	init(_ message: String, image: String, color: Color = .secondary) {
		self.msg = message
		self.icon = Image(image)
		self.color = color
	}

	var body: some View {
		VStack {
			ProgressView(label: {
				Label(
					title: {
						Text(self.msg)
					},
					icon: {
						self.icon
							.foregroundStyle(self.color)
					})
			})
		}.frame(maxWidth: .infinity, minHeight: 100)
	}
}

#Preview {
	List {
		LoadingView("Loading Project", systemImage: "app.gift.fill")
		LoadingView("Loading MR", image: "git-mr.symbols")
	}
}
