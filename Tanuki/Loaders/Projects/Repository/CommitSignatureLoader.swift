//
//  VerificationLoader.swift
//  GitLab
//
//  Created by Felix Schindler on 25.02.24.
//

import SwiftUI

private struct CommitSignature: Codable {
	let signatureType: String
	let verificationStatus: String
}

struct SignatureLoader: View {
	private var projectId: Int
	private var commitId: String

	init(projectId: Int, commitId: String) {
		self.projectId = projectId
		self.commitId = commitId
	}

	@State private var signature: CommitSignature? = nil
	@State private var showDetails = false

	private func loadSignature() async {
		do {
			self.signature = try await API.get(
				type: CommitSignature.self,
				endpoint: "projects/\(projectId)/repository/commits/\(commitId)/signature"
			)
		} catch let error {
			logger.error("Ignored error: \(error.localizedDescription)")
		}
	}

	public var body: some View {
		VStack {
			if let signature {
				if signature.verificationStatus.starts(with: "verified") {
					RoundIconButton("Show signature", icon: "checkmark.seal") {
						showDetails = true
					}
					.tint(.green)
					.controlSize(.mini)
				} else {
					EmptyView()
				}
			}
		}.task {
			await loadSignature()
		}.sheet(isPresented: $showDetails) {
			VStack(alignment: .leading) {
				if let signature {
					if signature.verificationStatus.starts(with: "verified") {
						if signature.verificationStatus == "verified_system" {
							Text(
								"This commit was created in the GitLab UI, and signed with a GitLab-verified signature."
							)
						} else {
							Text(
								"This commit was signed using \(signature.signatureType) with a verified signature and the committer email was verified to belong to the same user."
							)
						}
					}
				}
			}
			.padding()
			.presentationDetents([.fraction(0.2), .medium])
		}
	}
}

#Preview {
	VStack {
		SignatureLoader(
			projectId: 33_025_310,
			commitId: "6335421aa5180cffb0b2c49e805be7724efe25ad"
		)
		SignatureLoader(
			projectId: 278_964,
			commitId: "b230964dbb178c7c2043ce9de6eabe8e6cf67d5f"
		)
	}
}
