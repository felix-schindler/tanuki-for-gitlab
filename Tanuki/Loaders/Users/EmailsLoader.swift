//
//  EmailsLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 08.10.26.
//

import GitLabAPI
import SwiftUI

struct EmailsLoader: View {
	@State
	private var emails: Result<[CurrentUserEmailsQuery.Data.CurrentUser.Emails.Node?], Error>? = nil

	@State private var showAdd = false
	@State private var newEmail = ""

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

	private func addEmail() async {
		do {
			_ = try await API.req(
				type: RestAPIEmail.self,
				method: .post,
				endpoint: "user/emails",
				body: ["email": newEmail],
				contentType: .formUrlEncoded
			)

			newEmail = ""
			showAdd = false
			await reloadEmails()
		} catch let error {
			Notify.status(.error, "Couldn't add email", error.localizedDescription)
		}
	}

	private func deleteEmail(
		_ email: CurrentUserEmailsQuery.Data.CurrentUser.Emails.Node
	) async {
		do {
			guard let id = email.id.toIntId() else {
				return
			}

			try await API.delete(endpoint: "user/emails/\(id)")
			await reloadEmails()
		} catch let error {
			Notify.status(.error, "Couldn't delete email", error.localizedDescription)
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
							lucide: .mail
						)
					} else {
						ForEach(emails, id: \.self?.id) { email in
							if let email {
								HStack {
									Text(email.email)
										.textSelection(.enabled)
									Spacer()
									if email.confirmedAt != nil {
										LucideLabelIcon(.badgeCheck, color: .green)
									} else {
										LucideLabelIcon(.badgeX, color: .red)
									}
								}.swipeActions(edge: .trailing, allowsFullSwipe: true) {
									Button(role: .destructive) {
										Task {
											await deleteEmail(email)
										}
									} label: {
										Label("Delete", lucide: .trash)
									}
								}
							}
						}
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading Emails", lucide: .mail)
			}
		}.task {
			await loadEmails()
		}.refreshable {
			await reloadEmails()
		}.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button("Add", lucide: .plus) {
					showAdd = true
				}
			}
		}.sheet(isPresented: $showAdd) {
			NavigationStack {
				Form {
					TextField("user@example.com", text: $newEmail)
						.textInputAutocapitalization(.never)
						.keyboardType(.emailAddress)
				}.toolbar {
					AsyncButton("Save", lucide: .check) {
						await addEmail()
					}
					.tint(.accentColor)
					.disabled(newEmail.isEmpty)
				}.navigationTitle("New Email")
			}
		}.navigationTitle("Emails")
	}
}

#Preview {
	NavigationStack {
		EmailsLoader()
	}
}
