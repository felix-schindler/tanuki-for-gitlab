//
//  CurrentUserLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 29.02.24.
//

import GitLabAPI
import SwiftUI

struct CurrentUserLoader: View {

	@State
	private var loader = ApolloLoader<CurrentUserQuery, CurrentUserQuery.Data.CurrentUser> {
		$0.currentUser
	}

	public var body: some View {
		let state = loader.state

		List {
			if state.isInitialLoading {
				LoadingView("Loading Profile", systemImage: Icons.users.rawValue)
			} else if state.isColdFailure, let error = state.error {
				FailedView(error)
			} else if let user = state.value {
				UserView(user, isSelf: true)

				Section("Account") {
					NavigationLink(destination: KeysLoader()) {
						Label("SSH keys", systemImage: Icons.key.rawValue)
					}
					NavigationLink(destination: EmailsLoader()) {
						Label("Email addresses", systemImage: Icons.email.rawValue)
					}
				}
			}
		}.task {
			await loader.load(CurrentUserQuery())
		}.refreshable {
			await loader.reload(CurrentUserQuery())
		}.toolbar {
			ToolbarItem(placement: .topBarLeading) {
				NavigationLink(
					destination: SettingsView(),
					label: {
						Label("Settings", systemImage: Icons.settings.rawValue)
					})
			}

			ToolbarItem(placement: .topBarTrailing) {
				if let user = loader.state.value,
					let url = URL(string: user.webUrl)
				{
					ShareButton(url)
				}
			}
		}.navigationTitle("Profile")
	}
}

#Preview {
	NavigationStack {
		CurrentUserLoader()
	}
}
