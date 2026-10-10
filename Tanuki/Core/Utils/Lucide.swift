//
//  Lucide.swift
//  Tanuki
//
//  Created by Felix Schindler on 10.10.26.
//

import Lucide
import SwiftUI
import UIKit

/// Renders Lucide icons to cached template UIImages, so they also work in
/// UIKit-bridged containers (tab bar, toolbar) which only accept real Images.
@MainActor
enum LucideRenderer {
	private static var cache: [String: UIImage] = [:]

	static func image(_ icon: LucideIcon, size: CGFloat) -> UIImage {
		let key = "\(icon.rawValue)@\(Int(size))"
		if let cached = cache[key] {
			return cached
		}
		let renderer = ImageRenderer(
			content: Lucide(icon)
				.foregroundStyle(.black)
				.frame(width: size, height: size)
		)
		renderer.scale = 3
		let image = renderer.uiImage ?? UIImage()
		cache[key] = image
		return image
	}
}

/// Fixed-size Lucide icon for use in labels, buttons and rows.
public struct LucideLabelIcon: View {
	let icon: LucideIcon
	var color: Color?
	var size: CGFloat = 24

	public init(_ icon: LucideIcon, color: Color? = nil, size: CGFloat = 24) {
		self.icon = icon
		self.color = color
		self.size = size
	}

	@ViewBuilder
	public var body: some View {
		if let color {
			lucideImage.foregroundStyle(color)
		} else {
			lucideImage
		}
	}

	private var lucideImage: some View {
		Image(uiImage: LucideRenderer.image(icon, size: size))
			.renderingMode(.template)
			.resizable()
			.scaledToFit()
			.frame(width: size, height: size)
	}
}

extension Label where Title == Text, Icon == LucideLabelIcon {
	@MainActor public init(
		_ titleKey: LocalizedStringKey, lucide: LucideIcon, color: Color? = nil,
		size: CGFloat = 24
	) {
		self.init {
			Text(titleKey)
		} icon: {
			LucideLabelIcon(lucide, color: color, size: size)
		}
	}

	@MainActor public init<S: StringProtocol>(
		_ title: S, lucide: LucideIcon, color: Color? = nil, size: CGFloat = 24
	) {
		self.init {
			Text(title)
		} icon: {
			LucideLabelIcon(lucide, color: color, size: size)
		}
	}
}

extension Button where Label == SwiftUI.Label<Text, LucideLabelIcon> {
	@MainActor public init(
		_ titleKey: LocalizedStringKey, lucide: LucideIcon, color: Color? = nil,
		size: CGFloat = 24, role: ButtonRole? = nil, action: @escaping () -> Void
	) {
		self.init(role: role, action: action) {
			SwiftUI.Label(titleKey, lucide: lucide, color: color, size: size)
		}
	}

	@MainActor public init<S: StringProtocol>(
		_ title: S, lucide: LucideIcon, color: Color? = nil, size: CGFloat = 24,
		role: ButtonRole? = nil, action: @escaping () -> Void
	) {
		self.init(role: role, action: action) {
			SwiftUI.Label(title, lucide: lucide, color: color, size: size)
		}
	}
}

extension Menu where Label == SwiftUI.Label<Text, LucideLabelIcon> {
	@MainActor public init(
		_ titleKey: LocalizedStringKey, lucide: LucideIcon, color: Color? = nil,
		size: CGFloat = 24, @ViewBuilder content: @escaping () -> Content
	) {
		self.init {
			content()
		} label: {
			SwiftUI.Label(titleKey, lucide: lucide, color: color, size: size)
		}
	}

	@MainActor public init<S: StringProtocol>(
		_ title: S, lucide: LucideIcon, color: Color? = nil, size: CGFloat = 24,
		@ViewBuilder content: @escaping () -> Content
	) {
		self.init {
			content()
		} label: {
			SwiftUI.Label(title, lucide: lucide, color: color, size: size)
		}
	}
}
