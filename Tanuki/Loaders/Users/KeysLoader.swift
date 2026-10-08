//
//  KeysLoader.swift
//  Tanuki
//

import SwiftUI

struct SshKey: Codable {
	let id: Int
	let title: String
	let key: String
}

struct KeysLoader: View {
	@State
	private var keys: Result<[SshKey], Error>? = nil

	private func loadKeys() async {
		do {
			let temp = try await API.get(type: [SshKey].self, endpoint: "user/keys")

			self.keys = .success(temp)
		} catch let error {
			self.keys = .failure(error)
			Notify.status(.error)
		}
	}

	public var body: some View {
		List {
			if let keys {
				switch keys {
				case .success(let keys):
					if keys.isEmpty {
						NoContentView(
							"You'll see your SSH keys after you added them",
							systemImage: "key"
						)
					} else {
						ForEach(keys, id: \.id) { key in
							VStack(alignment: .leading) {
								Text(key.title)
									.font(.headline)
								Text(key.key)
									.font(.system(.footnote, design: .monospaced))
									.textSelection(.enabled)
							}
						}
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading SSH Keys", systemImage: "key")
			}
		}.task {
			await loadKeys()
		}.refreshable {
			await loadKeys()
		}.navigationTitle("SSH Keys")
	}
}

struct EmailAddress: Codable {
	let id: Int
	let email: String
	let confirmedAt: Date?
}

struct EmailsLoader: View {
	@State
	private var emails: Result<[EmailAddress], Error>? = nil

	private func loadEmails() async {
		do {
			let temp = try await API.get(type: [EmailAddress].self, endpoint: "user/emails")

			self.emails = .success(temp)
		} catch let error {
			self.emails = .failure(error)
			Notify.status(.error)
		}
	}

	public var body: some View {
		List {
			if let emails {
				switch emails {
				case .success(let emails):
					if emails.isEmpty {
						NoContentView(
							"You'll see your email addresses after you added them",
							systemImage: "envelope"
						)
					} else {
						ForEach(emails, id: \.id) { email in
							HStack {
								Text(email.email)
									.textSelection(.enabled)
								Spacer()
								if email.confirmedAt != nil {
									PillView("confirmed", cornerRadius: 5)
										.font(.footnote)
								} else {
									PillView("unconfirmed", cornerRadius: 5)
										.font(.footnote)
								}
							}
						}
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading Emails", systemImage: "envelope")
			}
		}.task {
			await loadEmails()
		}.refreshable {
			await loadEmails()
		}.navigationTitle("Emails")
	}
}

#Preview {
	NavigationStack {
		KeysLoader()
	}
}
