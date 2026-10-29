//
//  VisibilityIcon.swift
//  Tanuki
//
//  Created by Felix Schindler on 27.02.24.
//

import Lucide
import SwiftUI

struct VisibilityIcon: View {
	private let visibility: String
	private let icon: LucideIcon
	private let showText: Bool

	init(_ visibility: String, showText: Bool = false) {
		self.visibility = visibility
		self.showText = showText

		switch visibility {
		case "public":
			icon = .globe
			break
		case "internal":
			icon = .shieldHalf
			break
		case "private":
			icon = .lock
			break
		default:
			icon = .circleQuestionMark
			break
		}
	}

	public var body: some View {
		if showText {
			Label(self.visibility.capitalized, lucide: icon)
				.labelStyle(.titleAndIcon)
		} else {
			Label(self.visibility.capitalized, lucide: icon)
				.labelStyle(.iconOnly)
		}
	}
}

#Preview {
	VisibilityIcon("public")
}
