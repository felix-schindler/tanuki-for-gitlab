//
//  AddInstanceView.swift
//  Tanuki
//
//  Created by Felix Schindler on 12.11.26.
//

import AuthenticationServices
import SwiftUI

struct AddInstanceView: View {
	@Environment(\.webAuthenticationSession) private var webAuthenticationSession
	@Environment(\.dismiss) private var dismiss

	@State private var errorMessage: String?

	var body: some View {
		Form {
			if let errorMessage {
				Section {
					Text(errorMessage)
						.foregroundStyle(.red)
						.font(.footnote)
						.multilineTextAlignment(.center)
				}
			}

			Section {
				AsyncButton(action: { await login() }) {
					Label("GitLab.com (OAuth)", systemImage: "person.badge.key")
				}
				NavigationLink(destination: ConfigView()) {
					Label("Self-Hosted", systemImage: "server.rack")
				}
			} footer: {
				Text("OAuth opens gitlab.com in a browser. Self-hosted instances sign in with a personal access token.")
			}
		}.navigationTitle("Add Instance")
	}

	private func login() async {
		errorMessage = nil
		do {
			try await Auth.loginWithOAuth(
				using: webAuthenticationSession,
				dismiss: dismiss
			)
		} catch OAuthError.cancelled {
			// The user dismissed the browser sheet on purpose.
		} catch let error {
			errorMessage = "Failed to log in: \(error.localizedDescription)"
		}
	}
}

#Preview {
	NavigationStack {
		AddInstanceView()
	}
}
