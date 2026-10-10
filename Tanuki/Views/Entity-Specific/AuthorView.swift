//
//  TinyUserView.swift
//  Tanuki
//
//  Created by Felix Schindler on 01.03.24.
//

import SwiftUI

struct AuthorView: View {
	private let author: Author
	private let showUsername: Bool

	init(_ author: Author, showUsername: Bool = false) {
		self.author = author
		self.showUsername = showUsername
	}

	public var body: some View {
		NavigationLink(
			destination: UserLoader(username: author.username),
			label: {
				Label(
					title: {
						Text(
							author.name.isEmpty || showUsername
								? "@\(author.username)"
								: author.name
						)
					},
					icon: {
						if let url = URL.fromAvatar(author.avatarUrl) {
							AvatarImage(url, size: .tiny)
						} else {
							LucideLabelIcon(.user, size: 17)
						}
					}
				)
			}
		)
		.controlSize(.mini)
		.adaptiveButtonStyleProminent()
		.buttonBorderShape(.capsule)
	}
}

#Preview {
	NavigationStack {
		AuthorView(
			MyAuthor(
				avatarUrl: nil,
				name: "Felix",
				username: "felix-schindler"
			),
			showUsername: false
		)
	}
}
