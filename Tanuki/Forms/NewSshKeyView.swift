//
//  NewSshKeyView.swift
//  Tanuki
//
//  Created by Felix Schindler on 12.11.26.
//

import SwiftUI

struct NewSshKeyView: View {
	@Environment(\.dismiss) private var dismiss

	@State private var title = ""
	@State private var key = ""
	@State private var setExpiration = false
	@State private var expiresAt = Calendar.current.date(byAdding: .month, value: 1, to: Date())!

	private var trimmedTitle: String {
		title.trimmingCharacters(in: .whitespacesAndNewlines)
	}

	private var trimmedKey: String {
		key.trimmingCharacters(in: .whitespacesAndNewlines)
	}

	private var canSubmit: Bool {
		trimmedTitle.isNotEmpty && trimmedKey.isNotEmpty
	}

	private func addKey() async {
		guard canSubmit else {
			Notify.status(.error, "Please enter a title and a public key.")
			return
		}

		var body: [String: EncodableValue] = [
			"title": .string(trimmedTitle),
			"key": .string(trimmedKey),
		]

		if setExpiration {
			let formatter = DateFormatter()
			formatter.dateFormat = "yyyy-MM-dd"
			body["expires_at"] = .string(formatter.string(from: expiresAt))
		}

		do {
			let added = try await API.req(
				type: RestAPISshKey.self,
				method: .post,
				endpoint: "user/keys",
				body: body
			)

			Notify.status(.success, "Added \(added.title)", systemImage: Icons.key.rawValue)
			self.dismiss()
		} catch let error {
			Notify.status(.error, "Couldn't add SSH key", error.localizedDescription)
		}
	}

	public var body: some View {
		Form {
			Section {
				TextField("Title (required)", text: $title)

				TextField("ssh-ed25519 AAAA… user@example.com", text: $key, axis: .vertical)
					.font(.system(.footnote, design: .monospaced))
					.lineLimit(3...8)
					.textInputAutocapitalization(.never)
					.autocorrectionDisabled()
			} header: {
				Text("Key")
			} footer: {
				Text(
					"Paste your public key, for example the contents of `~/.ssh/id_ed25519.pub`. The private key never leaves your device."
				)
			}

			Section {
				Toggle("Set expiration", isOn: $setExpiration)

				if setExpiration {
					DatePicker(
						"Expires", selection: $expiresAt, in: Date()...,
						displayedComponents: .date)
				}
			} footer: {
				if setExpiration {
					Text("The key stops working after this date.")
				}
			}
		}.toolbar {
			ToolbarItem(placement: .cancellationAction) {
				Button("Cancel", role: .cancel) {
					self.dismiss()
				}
			}

			ToolbarItem(placement: .confirmationAction) {
				AsyncButton("Add key", systemImage: "checkmark") {
					await addKey()
				}.tint(.accentColor)
					.disabled(!canSubmit)
			}
		}
		.navigationTitle("New SSH Key")
		.scrollDismissesKeyboard(.interactively)
	}
}

#Preview {
	NavigationStack {
		NewSshKeyView()
	}
}
