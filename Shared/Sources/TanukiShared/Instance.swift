//
//  Instance.swift
//  TanukiShared
//

import Foundation

public struct GitLabInstance: Codable, Identifiable, Equatable, Sendable {
	public var id: String { host }
	public let host: String
	public let token: String
	public let isOAuth: Bool
	public let refreshToken: String?
	public let expiresAt: Date?

	public init(
		host: String,
		token: String,
		isOAuth: Bool = false,
		refreshToken: String? = nil,
		expiresAt: Date? = nil
	) {
		self.host = host
		self.token = token
		self.isOAuth = isOAuth
		self.refreshToken = refreshToken
		self.expiresAt = expiresAt
	}

	public var isValid: Bool {
		!token.isEmpty && !host.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
	}

	public var needsTokenRefresh: Bool {
		guard isOAuth, refreshToken?.isNotEmpty == true else {
			return false
		}
		guard let expiresAt else {
			return true
		}
		return expiresAt < Date().addingTimeInterval(300)
	}

	public static func normalizedHost(from input: String) -> String? {
		let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
		guard trimmed.isNotEmpty else { return nil }

		let candidate = trimmed.contains("://") ? trimmed : "https://\(trimmed)"
		guard let url = URL(string: candidate),
			let scheme = url.scheme?.lowercased(), scheme == "http" || scheme == "https",
			let parsedHost = url.host()?.lowercased(), parsedHost.isNotEmpty
		else {
			return nil
		}

		var authority = parsedHost
		if let port = url.port, port != 443, port != 80 {
			authority += ":\(port)"
		}

		var segments = url.pathComponents.filter { $0 != "/" && !$0.isEmpty }
		// Pasting the REST root should still configure the instance itself.
		if Array(segments.suffix(2)) == ["api", "v4"] {
			segments.removeLast(2)
		}
		if segments.count > 1 {
			segments.removeAll()
		}

		return segments.isEmpty ? authority : authority + "/" + segments.joined(separator: "/")
	}
}
