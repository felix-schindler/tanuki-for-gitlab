//
//  EmailsLoader.swift
//  Tanuki
//

import GitLabAPI
import SwiftUI

struct EmailsLoader: View {
	@State
	private var emails: Result<[CurrentUserEmailsQuery.Data.CurrentUser.Emails.Node?], Error>? = nil

	private func loadEmails() async {
		do {
			let responses = try Network.shared.apollo.fetch(
				query: CurrentUserEmailsQuery(), cachePolicy: .cacheAndNetwork)

			Task {
				for try await response in responses {
					if let emails = response.data?.currentUser?.emails?.nodes {
						self.emails = .success(emails)
					} else if let errors = response.errors {
						for error in errors {
							Notify.status(.error, error.localizedDescription)
						}
					}
				}
			}
		} catch let error {
			self.emails = .failure(error)
			Notify.status(.error)
		}
	}

	private func reloadEmails() async {
		do {
			let response = try await Network.shared.apollo.fetch(
				query: CurrentUserEmailsQuery(), cachePolicy: .networkOnly)

			if let emails = response.data?.currentUser?.emails?.nodes {
				self.emails = .success(emails)
			}

			Notify.status(.success)
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
						ForEach(emails, id: \.self?.id) { email in
							if let email {
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
			await reloadEmails()
		}.navigationTitle("Emails")
	}
}

#Preview {
	NavigationStack {
		EmailsLoader()
	}
}
