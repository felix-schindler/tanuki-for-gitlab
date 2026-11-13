//
//  EmojiHelper.swift
//  Tanuki
//
//  Created by Felix Schindler on 02.11.21.
//

import Foundation

/// Replaces GitLab emoji shortcodes (`:smile:`) with their unicode emoji in a string.
///
/// The table in `Resources/emoji.json` is GitLab's own emoji list
/// (`gitlab-org/gitlab/fixtures/emojis/digests.json`, 3779 slugs, tone variants included).
public enum EmojiHelper {
	private static let emojiRegex = try? NSRegularExpression(
		pattern: "(:[a-z0-9-+_]+:)", options: .caseInsensitive)

	private static let emojiCodes: [String: String] = {
		guard let url = Bundle.module.url(forResource: "emoji", withExtension: "json"),
			let data = try? Data(contentsOf: url),
			let codes = try? JSONDecoder().decode([String: String].self, from: data)
		else {
			assertionFailure("emoji.json is missing from the bundle; shortcodes will not render")
			return [:]
		}
		return codes
	}()

	public static func emojizedStringWithString(text: String) -> String {
		guard let regex = emojiRegex else { return text }
		var resultText = text
		// NSRegularExpression ranges are UTF-16 code units, so this must not be `text.count`.
		let matchingRange = NSMakeRange(0, text.utf16.count)
		regex.enumerateMatches(
			in: text, options: .reportCompletion,
			range: matchingRange,
			using: {
				(
					result: NSTextCheckingResult?,
					flags: NSRegularExpression.MatchingFlags,
					stop: UnsafeMutablePointer<ObjCBool>
				) -> Void in
				if let result, result.resultType == .regularExpression {
					let range = result.range
					if range.location != NSNotFound {
						let code = (text as NSString).substring(with: range)
						let unicode = EmojiHelper.emojiAliases(key: code)
						if !unicode.isEmpty {
							resultText = resultText.replacingOccurrences(
								of: code, with: unicode)
						}
					}
				}
			})
		return resultText
	}

	/// Resolves a bare `:slug:` to its unicode emoji, returning the input unchanged if it
	/// is not a known shortcode. Slugs are matched case-sensitively.
	public static func emojiAliases(key: String) -> String {
		guard let regex = emojiRegex,
			regex.firstMatch(in: key, options: [], range: NSMakeRange(0, key.utf16.count)) != nil
		else {
			return key
		}
		return emojiCodes[key] ?? key
	}
}
