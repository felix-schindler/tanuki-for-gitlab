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
	private var loader = ApolloLoader<CurrentUserEmailsQuery, [EmailNode?]> {
		$0.currentUser?.emails?.nodes
	}

	@State private var showAdd = false
	@State private var emailToDelete: EmailNode?

	private func deleteEmail(_ email: EmailNode) async {
		do {
			guard let id = email.id.toIntId() else {
				Notify.status(.error, "Couldn't delete email", "The email has no valid ID.")
				return
			}

			try await API.delete(endpoint: "user/emails/\(id)")
			await loader.reload(CurrentUserEmailsQuery(), notify: false)

			Notify.status(.success, "Email address deleted", systemImage: Icons.email.rawValue)
		} catch let error {
			Notify.status(.error, "Couldn't delete email", error.localizedDescription)
		}
	}

	public var body: some View {
		let state = loader.state

		List {
			if state.isInitialLoading {
				LoadingView("Loading Emails", systemImage: Icons.email.rawValue)
			} else if state.isColdFailure, let error = state.error {
				FailedView(error)
			} else if let emails = state.value {
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
			}
		}.task {
			await loader.load(CurrentUserEmailsQuery())
		}.refreshable {
			await loader.reload(CurrentUserEmailsQuery())
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
					await loader.reload(CurrentUserEmailsQuery(), notify: false)
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
