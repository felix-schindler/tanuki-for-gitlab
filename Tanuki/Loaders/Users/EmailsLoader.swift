//
//  EmailsLoader.swift
//  Tanuki
//
//  Created by Felix Schindler on 08.10.26.
//

import GitLabAPI
import SwiftUI

private typealias EmailNode = CurrentUserEmailsQuery.Data.CurrentUser.Emails.Node

struct EmailsLoader: View {
	@State
	private var emails: Result<[EmailNode?], Error>? = nil

	@State private var showAdd = false
	@State private var emailToDelete: EmailNode?

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

	private func reloadEmails(notifySuccess: Bool = true) async {
		do {
			let response = try await Network.shared.apollo.fetch(
				query: CurrentUserEmailsQuery(), cachePolicy: .networkOnly)

			if let emails = response.data?.currentUser?.emails?.nodes {
				self.emails = .success(emails)
			}

			if notifySuccess {
				Notify.status(.success)
			}
		} catch let error {
			self.emails = .failure(error)
			Notify.status(.error)
		}
	}

	private func deleteEmail(_ email: EmailNode) async {
		do {
			guard let id = email.id.toIntId() else {
				Notify.status(.error, "Couldn't delete email", "The email has no valid ID.")
				return
			}

			try await API.delete(endpoint: "user/emails/\(id)")

			if case .success(let emails) = emails {
				self.emails = .success(emails.filter { $0?.id != email.id })
			}

			Notify.status(.success, "Email address deleted", systemImage: Icons.email.rawValue)
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
							systemImage: Icons.email.rawValue
						)
					} else {
						ForEach(emails, id: \.self?.id) { email in
							if let email {
								HStack {
									Text(email.email)
										.textSelection(.enabled)
									Spacer()
									if email.confirmedAt != nil {
										Image(systemName: "checkmark.seal.fill")
											.foregroundStyle(.green)
									} else {
										Image(systemName: "xmark.seal.fill")
											.foregroundStyle(.red)
									}
								}.swipeActions(edge: .trailing, allowsFullSwipe: true) {
									Button(role: .destructive) {
										emailToDelete = email
									} label: {
										Label("Delete", systemImage: "trash")
									}
								}
							}
						}
					}
				case .failure(let error):
					FailedView(error)
				}
			} else {
				LoadingView("Loading Emails", systemImage: Icons.email.rawValue)
			}
		}.task {
			await loadEmails()
		}.refreshable {
			await reloadEmails()
		}.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button("Add", systemImage: "plus") {
					showAdd = true
				}
			}
		}.sheet(
			isPresented: $showAdd,
			onDismiss: {
				Task {
					await reloadEmails(notifySuccess: false)
				}
			}
		) {
			NavigationStack {
				NewEmailView()
			}
		}.confirmationDialog(
			"Delete \(emailToDelete?.email ?? "email address")?",
			isPresented: Binding(
				get: { emailToDelete != nil },
				set: { if !$0 { emailToDelete = nil } }
			),
			titleVisibility: .visible
		) {
			Button("Delete", role: .destructive) {
				if let email = emailToDelete {
					Task {
						await deleteEmail(email)
					}
				}
				emailToDelete = nil
			}
			Button("Cancel", role: .cancel) {
				emailToDelete = nil
			}
		} message: {
			Text("This address will be removed from your account. Your primary email can't be deleted.")
		}.navigationTitle("Emails")
	}
}

#Preview {
	NavigationStack {
		EmailsLoader()
	}
}
