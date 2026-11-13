//
//  PersistedCookies.swift
//  Tanuki
//
//  Created by Felix Schindler on 29.09.26.
//

import Foundation
import TanukiShared

enum PersistedCookies {
	private static let account = "persistedCookies"

	static func load() -> [[HTTPCookiePropertyKey: Any]] {
		guard let data = Keychain.data(for: account) ?? migrateFromUserDefaults(),
			let dicts = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)
				as? [[HTTPCookiePropertyKey: Any]]
		else {
			return []
		}
		return dicts
	}

	/// Moves the pre-Keychain copy, which was stored in clear text, and deletes it.
	private static func migrateFromUserDefaults() -> Data? {
		guard let legacy = UserDefaults.standard.data(forKey: account) else {
			return nil
		}
		Keychain.set(legacy, for: account)
		guard Keychain.data(for: account) != nil else {
			return legacy
		}
		UserDefaults.standard.removeObject(forKey: account)
		return legacy
	}

	static func loadCookies() -> [HTTPCookie] {
		load().compactMap { HTTPCookie(properties: $0) }
	}

	static func save(_ cookies: [HTTPCookie]) {
		let propertyDicts: [[HTTPCookiePropertyKey: Any]] = cookies.compactMap { $0.properties }
		guard !propertyDicts.isEmpty else { return }
		if let data = try? PropertyListSerialization.data(
			fromPropertyList: propertyDicts, format: .binary, options: 0)
		{
			Keychain.set(data, for: account)
		}
	}

	static func clear() {
		Keychain.remove(account)
		// Without this the clear-text copy is migrated back on the next load.
		UserDefaults.standard.removeObject(forKey: account)
	}
}
