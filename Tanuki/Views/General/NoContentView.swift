//
//  NoContentView.swift
//  Tanuki
//
//  Created by Felix Schindler on 21.09.25.
//

import SwiftUI

struct NoContentView: View {
	private let msg: String
	private let image: Image
	private let description: String?

	init(_ message: String, systemImage: String, description: String? = nil) {
		self.msg = message
		self.image = Image(systemName: systemImage)
		self.description = description
	}

	init(_ message: String, image: String, description: String? = nil) {
		self.msg = message
		self.image = Image(image)
		self.description = description
	}

	var body: some View {
		VStack {
			self.image
				.resizable()
				.scaledToFit()
				.foregroundStyle(.secondary)
				.frame(width: 40, height: 40)
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
			systemImage: "checkmark.square",
			description: "There are no Todos"
		)
		NoContentView(
			"All caught up!",
			systemImage: "checkmark",
			description: "There are no Todos"
		)
		NoContentView(
			"All caught up!",
			image: "git-mr-closed.symbols",
			description: "There are no Todos"
		)
		NoContentView(
			"All caught up!",
			image: "git-mr.symbols",
			description: "There are no Todos"
		)
	}
}
