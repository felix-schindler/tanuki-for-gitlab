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
	private var loader = ApolloLoader<UserQuery, UserQuery.Data.User> { $0.user }

	init(username: String) {
		self.username = username
	}

	public var body: some View {
		let state = loader.state

		List {
			if state.isInitialLoading {
				LoadingView("Loading user \(self.username)", systemImage: Icons.users.rawValue)
			} else if state.isColdFailure, let error = state.error {
				FailedView(error)
			} else if let user = state.value {
				UserView(user, isSelf: false)
			}
		}.task {
			await loader.load(UserQuery(username: self.username))
		}.refreshable {
			await loader.reload(UserQuery(username: self.username))
		}.toolbar {
			if let user = loader.state.value,
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
