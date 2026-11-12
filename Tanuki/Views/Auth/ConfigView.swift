//
//  ConfigView.swift
//  Tanuki
//
//  Created by Felix Schindler on 11.09.25.
//

import SwiftUI

struct ConfigView: View {
	@Environment(\.dismiss) var dismiss

	@State
	private var newHost = "gitlab.com"

	@State
	private var newToken = ""

	@State
	private var errorMessage: String?

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

			Section(
				content: {
					TextField("gitlab.example.com", text: $newHost)
						.keyboardType(.URL)
						.textInputAutocapitalization(.never)
						.autocorrectionDisabled()
				},
				header: {
					Label("GitLab URL", systemImage: "link")
				})

			Section(
				content: {
					TextField("glpat-4Rzq-VKwapmWqj4MfBsi", text: $newToken)
						.textInputAutocapitalization(.never)
						.autocorrectionDisabled()
				},
				header: {
					Label("Personal Access Token", systemImage: "key")
				})

			Section(
				content: {
					VStack(alignment: .leading, spacing: 4) {
						Label("api", systemImage: "checkmark.circle")
						Label("read_repository", systemImage: "checkmark.circle")
					}.font(.footnote)
				},
				header: {
					Label("Required scopes", systemImage: "checkmark.circle.fill")
				},
				footer: {
					Text("The token needs access to the REST API v4 and the GraphQL API.")
				})
		}.toolbar {
			AsyncButton("Save", systemImage: "checkmark") {
				await save()
			}
		}
		.scrollDismissesKeyboard(.immediately)
		.navigationTitle("Self-Hosted")
	}

	private func save() async {
		errorMessage = nil

		let token = newToken.trimmingCharacters(in: .whitespacesAndNewlines)
		guard token.isNotEmpty else {
			errorMessage = "Please provide a personal access token."
			return
		}

		guard let host = GitLabInstance.normalizedHost(from: newHost) else {
			errorMessage = "Please provide a valid URL, e.g. gitlab.example.com."
			return
		}

		do {
			let instance = GitLabInstance(host: host, token: token)
			try await Auth.login(
				instance: instance,
				dismiss: dismiss
			)
		} catch let error {
			errorMessage = "Failed to log in: \(error.localizedDescription)"
		}
	}
}

#Preview {
	NavigationStack {
		ConfigView()
	}
}
