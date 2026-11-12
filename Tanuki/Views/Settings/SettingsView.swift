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

	@AppStorage(SettingsKey.appearance)
	private var appearance = ""

	public var body: some View {
		List {
			Section {
				Picker(
					"Appearance", systemImage: "circle.lefthalf.filled",
					selection: $appearance
				) {
					Text("System").tag("")
					Text("Light").tag("light")
					Text("Dark").tag("dark")
				}
			}

			Section {
				NavigationLink(destination: CacheView()) {
					Label("Cache", systemImage: Icons.cache.rawValue)
				}
				NavigationLink(destination: CookiesView()) {
					Label(
						title: { Text("Cookies") },
						icon: {
							Image(Images.cookie.rawValue)
						})
				}
				NavigationLink(destination: InstancesView()) {
					Label("Instances", systemImage: Icons.server.rawValue)
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
					Label("Feedback", systemImage: Icons.feedback.rawValue)
				}
				AppStoreReview()
			}

			Section {
				Link(destination: URL(string: "https://schindlerfelix.de/projects/tanuki/privacy")!) {
					Label("Privacy Policy", systemImage: "hand.raised")
				}
				Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
					Label("Terms of Use (EULA)", systemImage: Icons.files.rawValue)
				}
				Link(destination: URL(string: "https://github.com/felix-schindler/tanuki-ios")!) {
					Label("Source Code on GitHub", systemImage: Icons.code.rawValue)
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
