//
//  SetupView.swift
//  Tanuki
//
//  Created by Felix Schindler on 16.03.24.
//

import SwiftUI
import Textual

struct SetupView: View {
	@Environment(\.openURL) private var openURL

	/// For CSRF protection
	@State private var state = UUID().uuidString
	@State private var codeVerifier = Auth.generateCodeVerifier()

	private var codeChallenge: String {
		Auth.generateCodeChallenge(codeVerifier: self.codeVerifier)
	}

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

				Button(
					action: {
						var components = URLComponents()
						components.scheme = "https"
						components.host = "gitlab.com"
						components.path = "/oauth/authorize"
						components.queryItems = [
							URLQueryItem(name: "client_id", value: Auth.clientID),
							URLQueryItem(name: "code_challenge", value: self.codeChallenge),
							URLQueryItem(name: "code_challenge_method", value: "S256"),
							URLQueryItem(name: "redirect_uri", value: Auth.redirectUri),
							URLQueryItem(name: "response_type", value: "code"),
							URLQueryItem(name: "scope", value: Auth.scope),
							URLQueryItem(name: "state", value: self.state),
						]

						if let authURL = components.url {
							openURL(authURL)
						}
					},
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
		}.onOpenURL { url in
			switch url.relativePath {
			case "/callback":
				let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
				let queryItems = components?.queryItems

				if let code = queryItems?.first(where: { $0.name == "code" })?.value,
					let state = queryItems?.first(where: { $0.name == "state" })?.value
				{
					if state == self.state {
						Task {
							do {
								let auth = try await API.req(
									type: OAuthToken.self,
									method: .post,
									endpoint: "oauth/token",
									body: [
										"client_id": Auth.clientID,
										"code": code,
										"grant_type": "authorization_code",
										"redirect_uri": Auth.redirectUri,
										"code_verifier": self.codeVerifier,
									],
									contentType: .formUrlEncoded,
									auth: false,
									useBase: false
								)

								let instance = GitLabInstance(
									host: "gitlab.com",
									token: auth.accessToken,
									isOAuth: true,
									refreshToken: auth.refreshToken,
									expiresAt: auth.expiresAt
								)
								try await Auth.login(
									instance: instance
								)
							} catch let error {
								print(error)
								Notify.status(
									.error, "Failed to log in",
									error.localizedDescription,
									systemImage: "xmark"
								)
							}
						}
					} else {
						Notify.status(
							.error,
							"Couldn't log in",
							"State mismatch",
							systemImage: "exclamationmark.triangle"
						)
					}
				} else {
					Notify.status(
						.error,
						"Couldn't log in",
						"Malformed URL",
						systemImage: "exclamationmark.triangle"
					)
				}
			default:
				Notify.status(
					.warning,
					"Can't handle URL", "You need to log in first",
					systemImage: "exclamationmark.triangle"
				)
			}
		}
	}
}

#Preview {
	SetupView()
}
