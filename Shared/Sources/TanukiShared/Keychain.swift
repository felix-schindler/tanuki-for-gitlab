//
//  Keychain.swift
//  TanukiShared
//

import Foundation
import Security

public enum Keychain {
	private static let service = "de.schindlerfelix.GitLab"

	public static func data(for account: String) -> Data? {
		var query = baseQuery(account: account)
		query[kSecReturnData as String] = true
		query[kSecMatchLimit as String] = kSecMatchLimitOne

		var result: AnyObject?
		guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess else {
			return nil
		}
		return result as? Data
	}

	public static func set(_ data: Data, for account: String) {
		let query = baseQuery(account: account)
		let attributes: [String: Any] = [
			kSecValueData as String: data,
			kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
		]

		if SecItemUpdate(query as CFDictionary, attributes as CFDictionary) == errSecItemNotFound {
			var item = query
			item.merge(attributes) { $1 }
			SecItemAdd(item as CFDictionary, nil)
		}
	}

	public static func remove(_ account: String) {
		SecItemDelete(baseQuery(account: account) as CFDictionary)
	}

	private static func baseQuery(account: String) -> [String: Any] {
		[
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: service,
			kSecAttrAccount as String: account,
		]
	}
}
