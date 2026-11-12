//
//  CommitSignature.swift
//  GitLab
//
//  Created by Felix Schindler on 25.02.24.
//

import Foundation

struct CommitSignature: Codable {
	let signatureType: String
	let verificationStatus: String

	/// Loads the signature details of a single commit.
	/// Only available through the REST API, the GraphQL commit selection just
	/// exposes the verification status.
	static func load(projectId: Int, commitId: String) async -> CommitSignature? {
		do {
			return try await API.get(
				type: CommitSignature.self,
				endpoint: "projects/\(projectId)/repository/commits/\(commitId)/signature"
			)
		} catch let error {
			logger.error("Ignored error: \(error.localizedDescription)")
			return nil
		}
	}
}
