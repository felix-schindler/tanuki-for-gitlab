//
//  TinyUserView.swift
//  Tanuki
//
//  Created by Felix Schindler on 01.03.24.
//

import SwiftUI
import TanukiShared

struct AuthorView: View {
	private let author: MyAuthor

	init(_ author: MyAuthor) {
		self.author = author
	}

	public var body: some View {
		Label(
			title: {
				Text(
					author.name.isEmpty
						? "@\(author.username)"
						: author.name
				)
			},
			icon: {
				if let url = URL.fromAvatar(author.avatarUrl) {
					AvatarImage(url, size: .tiny)
				} else {
					Image(
						systemName: "person"
					)
				}
			}
		)
		.buttonStyle(.plain)
		.tint(.primary)
		.padding(.horizontal, 8)
		.padding(.vertical, 3)
		.background(.secondary)
		.foregroundStyle(.primary)
		.cornerRadius(5)
	}
}
