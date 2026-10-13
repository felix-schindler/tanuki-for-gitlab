//
//  SettingsView.swift
//  Tanuki
//
//  Created by Felix Schindler on 23.11.25.
//

import LucideSwift
import SwiftUI

struct SettingsView: View {
	@AppStorage(SettingsKey.supportHtmlInMarkdown)
	private var supportHTML = false

	public var body: some View {
		List {
			Section {
				NavigationLink(destination: CacheView()) {
					Label("Cache", lucide: .hardDrive)
				}
				NavigationLink(destination: CookiesView()) {
					Label("Cookies", lucide: .cookie)
				}
				NavigationLink(destination: InstancesView()) {
					Label("Instances", lucide: .server)
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
					Label("Feedback", lucide: .messageCircle)
				}
				AppStoreReview()
			}

			Section {
				Link(destination: URL(string: "https://schindlerfelix.de/projects/tanuki/privacy")!) {
					Label("Privacy Policy", lucide: .hand)
				}
				Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
					Label("Terms of Use (EULA)", lucide: .fileText)
				}
				Link(destination: URL(string: "https://github.com/felix-schindler/tanuki-ios")!) {
					Label("Source Code on GitHub", lucide: .codeXml)
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
