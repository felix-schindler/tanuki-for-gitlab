//
//  RoundIconButton.swift
//  Tanuki
//
//  Created by Felix Schindler on 26.02.24.
//

import Lucide
import SwiftUI
import UIKit

struct CloseButton: View {
	private var action: () -> Void

	init(_ action: @escaping () -> Void) {
		self.action = action
	}

	public var body: some View {
		RoundIconButton("Close", icon: .x, action: action)
			.font(.system(size: 16, weight: .bold))
			.tint(.secondary)
	}
}

struct ShareButton: View {
	private let url: URL

	init(_ url: URL) {
		self.url = url
	}

	public var body: some View {
		ShareLink(item: url) {
			Label("Share", lucide: .squareArrowOutUpRight)
		}
	}
}

/// Presents the downloaded file immediately (ShareLink can't trigger programmatically).
enum ShareSheet {
	@MainActor
	static func present(for url: URL) {
		guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
			let root = windowScene.windows.first?.rootViewController
		else { return }
		let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
		if let popover = vc.popoverPresentationController {
			popover.sourceView = root.view
			popover.sourceRect = CGRect(
				x: root.view.bounds.midX, y: root.view.bounds.midY, width: 0, height: 0)
			popover.permittedArrowDirections = []
		}
		root.present(vc, animated: true)
	}
}

struct RoundIconButton: View {
	private let label: String
	private let icon: LucideIcon
	private let role: ButtonRole?
	private let action: () -> Void

	init(
		_ label: String, icon: LucideIcon, role: ButtonRole? = nil,
		action: @escaping () -> Void
	) {
		self.label = label
		self.icon = icon
		self.role = role
		self.action = action
	}

	public var body: some View {
		Button(label, lucide: icon, role: role, action: action)
			.frame(minWidth: 30, minHeight: 30)
			.adaptiveButtonStyle()
			.buttonBorderShape(.circle)
			.labelStyle(.iconOnly)
	}
}

#Preview {
	HStack {
		VStack {
			ShareButton(URL(string: "https://schindlerfelix.de")!)
			ShareButton(URL(string: "https://gitlab.com")!)
			ShareButton(
				URL(string: "https://gitlab.com/felix-schindler/gitlab-ios")!)
		}
		VStack {
			RoundIconButton("Up", icon: .arrowUp, action: {})
			RoundIconButton(
				"Filters", icon: .listFilter, action: {})
			RoundIconButton("Add", icon: .plus) {
			}
			RoundIconButton("Events", icon: .bell, action: {})
			CloseButton({})
			RoundIconButton("Cancel", icon: .x, action: {})
				.tint(.secondary)
			RoundIconButton("Cancel", icon: .x, action: {})
				.tint(.red)
		}
	}
}
