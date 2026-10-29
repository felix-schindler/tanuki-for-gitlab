//
//  VisibilityIcon.swift
//  Tanuki
//
//  Created by Felix Schindler on 27.02.24.
//

import SwiftUI

struct VisibilityIcon: View {
	private let visibility: String
	private let systemName: String
	private let showText: Bool

	init(_ visibility: String, showText: Bool = false) {
		self.visibility = visibility
		self.showText = showText

		switch visibility {
		case "public":
			systemName = "globe"
			break
		case "internal":
			systemName = "shield.lefthalf.filled"
			break
		case "private":
			systemName = "lock"
			break
		default:
			systemName = "questionmark"
			break
		}
	}

	public var body: some View {
		if showText {
			Label(self.visibility.capitalized, systemImage: systemName)
				.labelStyle(.titleAndIcon)
		} else {
			Label(self.visibility.capitalized, systemImage: systemName)
				.labelStyle(.iconOnly)
		}
	}
}

#Preview {
	VisibilityIcon("public")
}
