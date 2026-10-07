//
//  SetupView.swift
//  Tanuki
//
//  Created by Felix Schindler on 16.03.24.
//

import AuthenticationServices
import SwiftUI
import Textual

struct SetupView: View {
	@Environment(\.webAuthenticationSession) private var webAuthenticationSession

	public var body: some View {
		NavigationStack {
			VStack {
				Spacer()

				HStack {
					if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
						let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
						let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
						let lastIcon = iconFiles.last,
						let iconImage = UIImage(named: lastIcon)
					{
						Image(uiImage: iconImage)
							.resizable()
							.scaledToFit()
							.cornerRadius(15)
							.frame(maxWidth: 70, maxHeight: 70)
					}
					InlineMarkdown("Welcome to \n**Tanuki for GitLab**")
				}

				Spacer()

				AsyncButton(
					action: { await self.login() },
					label: {
						Text("Login with GitLab.com")
							.frame(maxWidth: .infinity)
					}
				)
				.tint(.accentColor)
				.buttonBorderShape(.capsule)
				.buttonStyle(.borderedProminent)
				.controlSize(.large)

				NavigationLink(
					destination: ConfigView(showSetup: nil),
					label: {
						Text("Self-Hosted instance")
							.frame(maxWidth: .infinity)
					}
				)
				.tint(.accentColor)
				.buttonBorderShape(.capsule)
				.buttonStyle(.bordered)
				.controlSize(.large)

				Spacer()
			}
			.padding()
			.textFieldStyle(.roundedBorder)
		}
	}

	/// Presents the GitLab authorize page and stores the resulting instance.
	private func login() async {
		do {
			let token = try await OAuth.authorize(using: webAuthenticationSession)
			let instance = GitLabInstance(
				host: "gitlab.com",
				token: token.accessToken,
				isOAuth: true,
				refreshToken: token.refreshToken,
				expiresAt: token.expiresAt
			)
			try await Auth.login(instance: instance)
		} catch OAuthError.cancelled {
			// The user dismissed the browser sheet on purpose.
		} catch let error {
			Notify.status(
				.error,
				"Couldn't log in",
				error.localizedDescription,
				systemImage: "xmark"
			)
		}
	}
}

#Preview {
	SetupView()
}
