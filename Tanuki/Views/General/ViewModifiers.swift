//
//  ScrollDismissIfAvailable.swift
//  Tanuki
//
//  Created by Felix Schindler on 21.09.25.
//

import SwiftUI

struct LabelSpacingIfAvailable: ViewModifier {
	func body(content: Content) -> some View {
		if #available(iOS 26.0, *) {
			content.labelIconToTitleSpacing(5)
		} else {
			content
		}
	}
}

extension View {
	@ViewBuilder
	func adaptiveButtonStyle() -> some View {
		if #available(iOS 26.0, *) {
			self.buttonStyle(.glass)
		} else {
			self.buttonStyle(.bordered)
		}
	}

	@ViewBuilder
	func adaptiveButtonStyleProminent() -> some View {
		if #available(iOS 26.0, *) {
			self.buttonStyle(.glassProminent)
		} else {
			self.buttonStyle(.borderedProminent)
		}
	}
}
