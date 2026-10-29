//
//  UserLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 29.02.24.
//

import GitLabAPI
import SwiftUI

struct UserLoader: View {
	private let username: String

	@State
	private var user: Result<UserQuery.Data.User, Error>? = nil

	init(username: String) {
		self.username = username
	}

	private func loadUser() {
		do {
			let responses = try Network.shared.apollo.fetch(
				query: UserQuery(username: self.username), cachePolicy: .cacheAndNetwork)

			Task {
				for try await response in responses {
					if let user = response.data?.user {
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
				query: UserQuery(username: self.username), cachePolicy: .networkOnly)

			if let user = response.data?.user {
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
					UserView(user, isSelf: false)
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading user \(self.username)", lucide: .user)
			}
		}.task {
			loadUser()
		}.refreshable {
			await reloadUser()
		}.toolbar {
			if let user, case .success(let user) = user,
				let url = URL(string: user.webUrl)
			{
				ShareButton(url)
			}
		}
	}
}

#Preview {
	UserLoader(username: "felix-schindler")
}
