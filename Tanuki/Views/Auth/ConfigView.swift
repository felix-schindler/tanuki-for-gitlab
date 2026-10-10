//
//  ConfigView.swift
//  Tanuki
//
//  Created by Felix Schindler on 11.09.25.
//

import SwiftUI

struct ConfigView: View {
	@Environment(\.dismiss) var dismiss

	public private(set) var showSetup: Binding<Bool>? = nil

	@State
	private var newHost = "gitlab.com"

	@State
	private var newToken = ""

	var body: some View {
		VStack {
			Spacer()

			Label("GitLab URL", lucide: .link)
				.font(.headline)
			TextField("gitlab.com", text: self.$newHost)
				.keyboardType(.URL)
				.textInputAutocapitalization(.never)
				.autocorrectionDisabled()

			Label("Personal Access Token", lucide: .key)
				.padding(.top)
				.font(.headline)
			TextField("glpat-4Rzq-VKwapmWqj4MfBsi", text: self.$newToken)
				.textInputAutocapitalization(.never)
				.autocorrectionDisabled()

			VStack {
				Label("Requirements", lucide: .squareCheckBig)
					.font(.headline)
				Text("Access to the REST-API v4 and GraphQL API")

				Text("Scopes")
					.font(.subheadline)
					.padding(.top, 1)
				VStack(alignment: .leading) {
					Label("`api`", lucide: .circleCheck)
					Label("`read_repository`", lucide: .circleCheck)
				}.font(.footnote)
			}
			.padding(.top)

			Spacer()

			AsyncButton(
				action: {
					do {
						if newHost.contains("/") {
							if let tempUrl = URL(string: newHost),
								let _newHost = tempUrl.host
							{
								newHost = _newHost
							} else {
								Notify.status(.error, "Please only provide the host, not a URI")
								return
							}
						}

						let instance = GitLabInstance(
							host: self.newHost,
							token: self.newToken,
							isOAuth: false
						)
						try await Auth.login(
							instance: instance,
							showSetup: showSetup,
							dismiss: dismiss
						)
					} catch let error {
						Notify.status(
							.error,
							"Failed to log in",
							error.localizedDescription,
							systemImage: "xmark"
						)
					}
				},
				label: {
					Label("Save config", lucide: .check)
						.frame(maxWidth: .infinity)
				}
			)
			.tint(.accentColor)
			.buttonBorderShape(.capsule)
			.buttonStyle(.bordered)
			.controlSize(.large)
		}
		.padding()
		.textFieldStyle(.roundedBorder)
		.navigationTitle("Self-Hosted")
		.scrollDismissesKeyboard(.interactively)
	}
}

#Preview {
	NavigationStack {
		ConfigView(showSetup: .constant(true))
	}
}
