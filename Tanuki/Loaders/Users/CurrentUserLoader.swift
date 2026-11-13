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
	private var user: Result<CurrentUserQuery.Data.CurrentUser, Error>? = nil

	private func loadUser() async {
		do {
			let responses = try Network.shared.apollo.fetch(
				query: CurrentUserQuery(), cachePolicy: .cacheAndNetwork)

			Task {
				for try await response in responses {
					if let user = response.data?.currentUser {
						self.user = .success(user)
					} else if let errors = response.errors {
						for error in errors {
							Notify.status(.error, error.localizedDescription)
						}
					}
				}
			}
		} catch let error {
			self.user = .failure(error)
			Notify.status(.error)
		}
	}

	private func reloadUser() async {
		do {
			let response = try await Network.shared.apollo.fetch(
				query: CurrentUserQuery(), cachePolicy: .networkOnly)

			if let user = response.data?.currentUser {
				self.user = .success(user)
			}

			Notify.status(.success)
		} catch let error {
			self.user = .failure(error)
			Notify.status(.error)
		}
	}

	public var body: some View {
		List {
			if let user {
				switch user {
				case .success(let user):
					UserView(user, isSelf: true)

					Section("Account") {
						NavigationLink(destination: KeysLoader()) {
							Label("SSH keys", systemImage: Icons.key.rawValue)
						}
						NavigationLink(destination: EmailsLoader()) {
							Label("Email addresses", systemImage: Icons.email.rawValue)
						}
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading Profile", systemImage: Icons.users.rawValue)
			}
		}.task {
			await loadUser()
		}.refreshable {
			await reloadUser()
		}.toolbar {
			ToolbarItem(placement: .topBarLeading) {
				NavigationLink(
					destination: SettingsView(),
					label: {
						Label("Settings", systemImage: Icons.settings.rawValue)
					})
			}

			ToolbarItem(placement: .topBarTrailing) {
				if let user, case .success(let user) = user,
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
