//
//  JumpFailureView.swift
//  Tanuki
//
//  Created by Felix Schindler on 07.10.26.
//

import Lucide
import SwiftUI

struct JumpFailureView: View {
	private let diagnostics: JumpDiagnostics

	@State
	private var copied = false

	init(_ diagnostics: JumpDiagnostics) {
		self.diagnostics = diagnostics
	}

	private var headline: String {
		diagnostics.error?.title ?? "This link couldn't be opened"
	}

	private var targetLine: String {
		diagnostics.target?.describeTarget ?? "Nowhere — the link couldn't be read"
	}

	private var message: String {
		diagnostics.error?.message ?? "The app couldn't work out what this link points at."
	}

	public var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			HStack(alignment: .top, spacing: 10) {
				LucideLabelIcon(.triangleAlert, color: .yellow, size: 24)
				VStack(alignment: .leading, spacing: 2) {
					Text(headline)
						.font(.headline)
					Text(message)
						.font(.subheadline)
						.foregroundStyle(.secondary)
				}
			}

			details

			if let hint = diagnostics.error?.hint {
				Label(hint, lucide: .lightbulb)
					.font(.footnote)
					.foregroundStyle(.secondary)
			}

			Button {
				UIPasteboard.general.string = diagnostics.report
				copied = true
				Notify.status(.success, "Details copied", systemImage: "doc.on.doc")
			} label: {
				Label(copied ? "Details copied" : "Copy details", lucide: .copy)
			}
			.adaptiveButtonStyle()
			.font(.footnote)
		}
		.padding(.vertical, 4)
	}

	/// "Where did it try to go" answers, selectable so they can be copied by hand.
	private var details: some View {
		VStack(alignment: .leading, spacing: 6) {
			row("Tried to open", targetLine, lucide: .arrowRight)
			row("Signed in to", diagnostics.host, lucide: .server)
			row(
				"Clipboard", JumpURLError.excerpt(diagnostics.raw, limit: 240),
				lucide: .clipboardPaste, monospaced: true)
		}
		.padding(10)
		.background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 10))
	}

	private func row(
		_ title: String, _ value: String, lucide: LucideIcon, monospaced: Bool = false
	) -> some View {
		VStack(alignment: .leading, spacing: 1) {
			Label(title, lucide: lucide)
				.font(.caption)
				.foregroundStyle(.secondary)
			Text(value)
				.font(monospaced ? .footnote.monospaced() : .footnote)
				.textSelection(.enabled)
				.fixedSize(horizontal: false, vertical: true)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}
}

/// Compact version of ``JumpFailureView`` for the Home list.
struct JumpFailureCard: View {
	private let diagnostics: JumpDiagnostics
	private let onDismiss: () -> Void

	init(_ diagnostics: JumpDiagnostics, onDismiss: @escaping () -> Void) {
		self.diagnostics = diagnostics
		self.onDismiss = onDismiss
	}

	public var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			JumpFailureView(diagnostics)

			Button("Dismiss", lucide: .x) {
				onDismiss()
			}
			.font(.footnote)
			.foregroundStyle(.secondary)
		}
		.listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
	}
}

#Preview {
	List {
		JumpFailureCard(
			JumpDiagnostics(
				raw: "https://gitlab.com/group/project/-/issues/12", host: "gitlab.com",
				error: .wrongHost(urlHost: "gitlab.example.com", expectedHost: "gitlab.com")),
			onDismiss: {}
		)
	}
}
