//
//  NewEmailView.swift
//  Tanuki
//
//  Created by Felix Schindler on 12.11.26.
//

import SwiftUI

struct NewEmailView: View {
	@Environment(\.dismiss) private var dismiss

	@State private var email = ""

	private var trimmedEmail: String {
		email.trimmingCharacters(in: .whitespacesAndNewlines)
	}

	private var canSubmit: Bool {
		trimmedEmail.contains("@")
	}

	private func addEmail() async {
		guard canSubmit else {
			Notify.status(.error, "Please enter a valid email address.", systemImage: Icons.email.rawValue)
			return
		}

		do {
			_ = try await API.req(
				type: RestAPIEmail.self,
				method: .post,
				endpoint: "user/emails",
				body: ["email": trimmedEmail],
				contentType: .formUrlEncoded
			)

			Notify.status(.success, "Verification email sent", systemImage: Icons.email.rawValue)
			self.dismiss()
		} catch let error {
			Notify.status(.error, "Couldn't add email", error.localizedDescription)
		}
	}

	public var body: some View {
		Form {
			Section {
				TextField("user@example.com", text: $email)
					.textInputAutocapitalization(.never)
					.autocorrectionDisabled()
					.keyboardType(.emailAddress)
			} footer: {
				Text(
					"GitLab sends a confirmation email. The address can only be used once you confirm it."
				)
			}
		}.toolbar {
			ToolbarItem(placement: .cancellationAction) {
				Button("Cancel", role: .cancel) {
					self.dismiss()
				}
			}

			ToolbarItem(placement: .confirmationAction) {
				AsyncButton("Add email", systemImage: "checkmark") {
					await addEmail()
				}.tint(.accentColor)
					.disabled(!canSubmit)
			}
		}
		.navigationTitle("New Email")
		.scrollDismissesKeyboard(.interactively)
	}
}

#Preview {
	NavigationStack {
		NewEmailView()
	}
}
