//
//  Utils.swift
//  Tanuki
//
//  Created by Felix Schindler on 20.09.25.
//

import Foundation
import TanukiShared

// MARK: - URL helpers
extension URL {
	@MainActor
	public static func fromAvatar(_ avatarUrl: String?) -> URL? {
		if var urlStr = avatarUrl {
			if !urlStr.contains("://") {
				urlStr = "https://" + API.host + urlStr
			}

			return URL(string: urlStr)
		}

		return nil
	}
}

extension StringProtocol {
	/// Calipalize only the first character of a string
	var firstCapitalized: String {
		prefix(1).capitalized + dropFirst()
	}
}
