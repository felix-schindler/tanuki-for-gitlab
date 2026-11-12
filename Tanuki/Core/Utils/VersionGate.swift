//
//  VersionGate.swift
//  Tanuki
//
//  Created by Felix Schindler on 12.11.26.
//

import Foundation

/// Warns when an instance is older than the GitLab version Tanuki's GraphQL
/// schema and REST calls are built against. The warning is per instance and
/// server version, and can be acknowledged away.
@MainActor
enum VersionGate {
	/// The GraphQL schema is generated from GitLab 18.1; older instances are
	/// missing fields and answer with GraphQL errors.
	static let minimumRequiredVersion = "18.1.0"

	private static let acknowledgementsKey = "acknowledgedVersionWarnings"
	private static let userDefaults = UserDefaults(suiteName: "group.de.schindlerfelix.GitLab") ?? .standard

	private static var acknowledgedVersionWarnings: Set<String> {
		get {
			guard let data = userDefaults.data(forKey: acknowledgementsKey),
				let set = try? JSONDecoder().decode(Set<String>.self, from: data)
			else {
				return []
			}
			return set
		}
		set {
			if let data = try? JSONEncoder().encode(newValue) {
				userDefaults.set(data, forKey: acknowledgementsKey)
			}
		}
	}

	private static func key(for host: String, serverVersion: String) -> String {
		"\(host):\(minimumRequiredVersion):\(serverVersion)"
	}

	static func acknowledgeVersionWarning(for host: String, serverVersion: String) {
		var current = acknowledgedVersionWarnings
		current.insert(key(for: host, serverVersion: serverVersion))
		acknowledgedVersionWarnings = current
	}

	static func shouldShowVersionWarning(for host: String, serverVersion: String) -> Bool {
		compareVersions(serverVersion, minimumRequiredVersion) == .orderedAscending
			&& !acknowledgedVersionWarnings.contains(key(for: host, serverVersion: serverVersion))
	}

	/// Compares dotted version strings numerically, so `18.10` sorts after
	/// `18.2`. Pre-release/build suffixes (`-ee`, `-rc1`) are ignored.
	static func compareVersions(_ lhs: String, _ rhs: String) -> ComparisonResult {
		let left = numericComponents(lhs)
		let right = numericComponents(rhs)

		for index in 0..<max(left.count, right.count) {
			let leftPart = index < left.count ? left[index] : 0
			let rightPart = index < right.count ? right[index] : 0
			if leftPart < rightPart {
				return .orderedAscending
			}
			if leftPart > rightPart {
				return .orderedDescending
			}
		}
		return .orderedSame
	}

	private static func numericComponents(_ version: String) -> [Int] {
		var value = version.trimmingCharacters(in: .whitespacesAndNewlines)
		if value.hasPrefix("v") {
			value = String(value.dropFirst())
		}
		let core = value.split(separator: "-", maxSplits: 1).first.map(String.init) ?? value
		return core.split(separator: ".").compactMap { Int($0) }
	}
}
