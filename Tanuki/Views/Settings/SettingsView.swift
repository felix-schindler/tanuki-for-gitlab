//
//  SettingsView.swift
//  Tanuki
//
//  Created by Felix Schindler on 23.11.25.
//

import SwiftUI

struct SettingsView: View {
	@AppStorage(SettingsKey.supportHtmlInMarkdown)
	private var supportHTML = false

	public var body: some View {
		List {
			Section {
				NavigationLink(destination: CacheView()) {
					Label("Cache", systemImage: "internaldrive")
				}
				NavigationLink(destination: CookiesView()) {
					Label(
						title: { Text("Cookies") },
						icon: {
							Image("cookie.symbols")
								.resizable()
								.scaledToFit()
						})
				}
				NavigationLink(destination: InstancesView()) {
					Label("Instances", systemImage: "server.rack")
				}
			}

			Section("Markdown") {
				Toggle("Support HTML in Markdown", isOn: $supportHTML)
				Text(
					"Render descriptions and comments in a web view so raw HTML (for example <details> blocks) is shown. Inline text such as titles always renders natively."
				)
				.font(.footnote)
				.foregroundStyle(.secondary)
			}

			Section {
				NavigationLink(destination: FeedbackView()) {
					Label("Feedback", systemImage: "exclamationmark.bubble")
				}
				AppStoreReview()
			}

			Section {
				Link(destination: URL(string: "https://schindlerfelix.de/projects/tanuki/privacy")!) {
					Label("Privacy Policy", systemImage: "hand.raised")
				}
				Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
					Label("Terms of Use (EULA)", systemImage: "doc.text")
				}
				Link(destination: URL(string: "https://github.com/felix-schindler/tanuki-ios")!) {
					Label("Source Code on GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
				}
			}
		}
	}
}

#Preview {
	NavigationStack {
		SettingsView()
	}
}
