//
//  NoContentView.swift
//  Tanuki
//
//  Created by Felix Schindler on 21.09.25.
//

import Lucide
import SwiftUI

struct NoContentView: View {
	private let msg: String
	private let image: LucideIcon
	private let description: String?

	init(_ message: String, lucide: LucideIcon, description: String? = nil) {
		self.msg = message
		self.image = lucide
		self.description = description
	}

	var body: some View {
		VStack {
			LucideLabelIcon(image, size: 40)
				.foregroundStyle(.secondary)
				.padding(.bottom, 10)
			Text(self.msg)
				.font(.title2.bold())
			if let description {
				Text(description)
					.font(.callout)
					.foregroundStyle(.secondary)
			}
		}
		.padding()
		.frame(maxWidth: .infinity, minHeight: 100)
	}
}

#Preview {
	List {
		NoContentView(
			"All caught up!",
			lucide: .squareCheckBig,
			description: "There are no Todos"
		)
		NoContentView(
			"All caught up!",
			lucide: .check,
			description: "There are no Todos"
		)
		NoContentView(
			"All caught up!",
			lucide: .gitPullRequestClosed,
			description: "There are no Todos"
		)
		NoContentView(
			"All caught up!",
			lucide: .gitPullRequest,
			description: "There are no Todos"
		)
	}
}
