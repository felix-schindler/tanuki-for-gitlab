//
//  RoundIconButton.swift
//  Tanuki
//
//  Created by Felix Schindler on 26.02.24.
//

import SwiftUI
import UIKit

struct CloseButton: View {
	private var action: () -> Void

	init(_ action: @escaping () -> Void) {
		self.action = action
	}

	public var body: some View {
		RoundIconButton("Close", icon: "xmark", action: action)
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
			Label("Share", systemImage: "square.and.arrow.up")
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
	private let iconName: String
	private let action: () -> Void

	init(
		_ label: String, icon: String, role: ButtonRole? = nil,
		action: @escaping () -> Void
	) {
		self.label = label
		self.iconName = icon
		self.action = action
	}

	public var body: some View {
		Button(label, systemImage: iconName, action: action)
			.frame(minWidth: 30, minHeight: 30)
			.buttonStyle(.bordered)
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
			RoundIconButton("Up", icon: "arrow.up", action: {})
			RoundIconButton(
				"Filters", icon: "line.3.horizontal.decrease", action: {})
			RoundIconButton("Add", icon: "plus") {
			}
			RoundIconButton("Events", icon: "bell", action: {})
			CloseButton({})
			RoundIconButton("Cancel", icon: "xmark", action: {})
				.tint(.secondary)
			RoundIconButton("Cancel", icon: "xmark", action: {})
				.tint(.red)
		}
	}
}
