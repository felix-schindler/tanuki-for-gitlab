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
				VStack(alignment: .leading) {
					Image(systemName: "gear")
						.resizable()
						.scaledToFill()
						.foregroundStyle(.white)
						.frame(width: 50, height: 50)
						.padding(5)
						.background(.gray)
						.clipShape(RoundedRectangle(cornerRadius: 15.0))
						.padding(.bottom, 10)
					Text("Settings")
						.font(.title2.bold())
						.padding(.bottom, 1)
					Text("Clear caches, manage cookies, manage clipboard access, or submit feedback.")
						.font(.callout)
						.foregroundStyle(.secondary)
				}
			}

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
				// NavigationLink(destination: ClipboardAccess()) {
				// 	Label("Clipboard URL", systemImage: "arrow.right.page.on.clipboard")
				// }
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
