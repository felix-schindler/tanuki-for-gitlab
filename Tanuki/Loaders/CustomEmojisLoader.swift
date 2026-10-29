//
//  CustomEmojiLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 05.03.24.
//

import GitLabAPI
import SwiftUI

struct CustomEmojisLoader: View {
	private var fullPath: String

	@State
	private var emojis: Result<[GroupCustomEmojiQuery.Data.Group.CustomEmoji.Node?], Error>? = nil

	init(fullPath: String) {
		self.fullPath = fullPath
	}

	private func loadEmojis() {
		do {
			let responses = try Network.shared.apollo.fetch(
				query: GroupCustomEmojiQuery(fullPath: self.fullPath), cachePolicy: .cacheAndNetwork
			)

			Task {
				for try await response in responses {
					if let emojis = response.data?.group?.customEmoji?.nodes {
						self.emojis = .success(emojis)
					} else if let errors = response.errors {
						for error in errors {
							Notify.status(.error, error.localizedDescription)
						}
					}
				}
			}
		} catch let error {
			self.emojis = .failure(error)
			Notify.status(.error)
		}
	}

	private func reloadEmojis() async {
		do {
			let repsonse = try await Network.shared.apollo.fetch(
				query: GroupCustomEmojiQuery(fullPath: self.fullPath), cachePolicy: .networkOnly)

			if let emojis = repsonse.data?.group?.customEmoji?.nodes {
				self.emojis = .success(emojis)
			}

			Notify.status(.success)
		} catch let error {
			self.emojis = .failure(error)
			Notify.status(.error)
		}
	}

	public var body: some View {
		List {
			if let emojis {
				switch emojis {
				case .success(let emojis):
					if emojis.isEmpty {
						NoContentView(
							"There are no custom emojis", lucide: .faceSlightlySmiling)
					} else {
						ForEach(emojis, id: \.?.id) { maybeEmoji in
							if let emoji = maybeEmoji {
								HStack {
									if let url = URL(string: emoji.url) {
										AvatarImage(url)
									}
									VStack(alignment: .leading) {
										Text(emoji.name)
										PillView(Date.fromToString(emoji.createdAt), icon: .clock)
											.font(.footnote)
									}
								}
							}
						}
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading custom emojis", lucide: .faceSlightlySmiling)
			}
		}.task {
			loadEmojis()
		}.refreshable {
			await reloadEmojis()
		}.navigationTitle("Custom Emojis")
	}
}

#Preview {
	NavigationStack {
		CustomEmojisLoader(fullPath: "gitlab-org")
	}
}
