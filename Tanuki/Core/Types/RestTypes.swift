//
//  RestTypes.swift
//  Tanuki
//
//  Created by Felix Schindler on 03.03.24.
//

import Foundation

// MARK: - Authentication
struct OAuthToken: Codable, Sendable {
	let accessToken: String
	let tokenType: String
	let expiresIn: Int
	let refreshToken: String
	let createdAt: Int

	var expiresAt: Date {
		Date(timeIntervalSince1970: TimeInterval(createdAt)).addingTimeInterval(TimeInterval(expiresIn))
	}
}

struct RestAPIUser: Codable {
	let id: Int
	let username: String
	let name: String
	let avatarUrl: String?
	let webUrl: String
}

// MARK: - Events
struct Event: Codable {
	let id: Int
	let projectId: Int
	let actionName: String
	let targetIid: Int?
	let targetType: String?
	let targetTitle: String?
	let createdAt: Date
	let pushData: PushData?
	let author: MyAuthor
}

struct PushData: Codable {
	let refType: String
	let ref: String
	let commitTitle: String?
}

// MARK: - Projects
struct RestAPIProject: Codable {
	let id: Int
}

// MARK: - Labels
struct RestAPILabel: Codable {
	let id: Int
}

// MARK: - Users
struct UserSmall: Codable {
	let id: Int
}

struct RestAPIStatus: Codable {
	let message: String?
}

struct RestAPIEmail: Codable {
	let id: Int
	let email: String
}

// MARK: - Groups
struct RestAPIGroup: Codable {
	let id: Int
	let name: String?
	let fullPath: String?
}

// MARK: - Releases
struct RestAPIRelease: Codable {
	let name: String
}

// MARK: - Milestones
struct RestAPIMilestone: Codable {
	let iid: Int
}

// MARK: - Issues
struct RestAPIIssue: Codable {
	let iid: Int
}

// MARK: - Merge Requests
struct RestAPIMergeRequest: Codable {
	let iid: Int
	let state: String
}

// MARK: - Snippets
struct RestAPISnippet: Codable {
	let id: Int
	let title: String
}
