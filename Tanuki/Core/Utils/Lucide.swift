//
//  Lucide.swift
//  Tanuki
//
//  Created by Felix Schindler on 10.10.26.
//

import LucideSwift
import SwiftUI

extension Label where Title == Text, Icon == LucideIcon {
	@MainActor public init(
		_ titleKey: LocalizedStringKey, lucide: LucideIconName, color: Color,
		size: CGFloat = 24
	) {
		self.init {
			Text(titleKey)
		} icon: {
			LucideIcon(lucide, size: size, color: color)
		}
	}

	@MainActor public init<S: StringProtocol>(
		_ title: S, lucide: LucideIconName, color: Color, size: CGFloat = 24
	) {
		self.init {
			Text(title)
		} icon: {
			LucideIcon(lucide, size: size, color: color)
		}
	}
}

/// Buttons and menus bridge to UIKit (toolbar, tab bar, UIMenu), which only
/// accepts real Images — so these build Image-based labels, unlike the
/// vector-based Label extension above.
extension Button where Label == SwiftUI.Label<Text, Image> {
	@MainActor public init(
		_ titleKey: LocalizedStringKey, lucide: LucideIconName, role: ButtonRole? = nil,
		action: @escaping () -> Void
	) {
		self.init(role: role, action: action) {
			SwiftUI.Label {
				Text(titleKey)
			} icon: {
				Image(lucide: lucide)
			}
		}
	}

	@MainActor public init<S: StringProtocol>(
		_ title: S, lucide: LucideIconName, role: ButtonRole? = nil,
		action: @escaping () -> Void
	) {
		self.init(role: role, action: action) {
			SwiftUI.Label {
				Text(title)
			} icon: {
				Image(lucide: lucide)
			}
		}
	}
}

extension Menu where Label == SwiftUI.Label<Text, Image> {
	@MainActor public init(
		_ titleKey: LocalizedStringKey, lucide: LucideIconName,
		@ViewBuilder content: @escaping () -> Content
	) {
		self.init {
			content()
		} label: {
			SwiftUI.Label {
				Text(titleKey)
			} icon: {
				Image(lucide: lucide)
			}
		}
	}

	@MainActor public init<S: StringProtocol>(
		_ title: S, lucide: LucideIconName, @ViewBuilder content: @escaping () -> Content
	) {
		self.init {
			content()
		} label: {
			SwiftUI.Label {
				Text(title)
			} icon: {
				Image(lucide: lucide)
			}
		}
	}
}
