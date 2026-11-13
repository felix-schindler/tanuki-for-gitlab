//
//  CodeTextView.swift
//  Tanuki
//
//  Created by Felix Schindler on 07.04.24.
//

import Highlightr
import SwiftUI

/// Inspiration from: https://github.com/mortenjust/CodeHighlighter
/// See: https://highlightjs.org and https://github.com/raspu/Highlightr
public struct CodeTextView: View {
	private let code: String
	private let language: String
	private let theme: String
	private let fontSize: Double

	@State
	private var highlightedCode: AttributedString

	public init(
		_ code: String,
		language: String,
		colorScheme: ColorScheme,
		lightTheme: String = "vs",
		darkTheme: String = "vs2015",
		fontSize: Double = 12
	) {
		self.code = code
		self.language = language.lowercased()
		self.theme = colorScheme == .dark ? darkTheme : lightTheme
		self.fontSize = fontSize
		_highlightedCode = State(initialValue: CodeHighlighter.styled(AttributedString(code), fontSize: fontSize))
	}

	public var body: some View {
		Text(highlightedCode)
			.lineSpacing(4)
			.textSelection(.enabled)
			.task(id: HighlightRequest(code: code, language: language, theme: theme, fontSize: fontSize)) {
				highlightedCode = await CodeHighlighter.shared.highlight(
					code,
					language: language,
					theme: theme,
					fontSize: fontSize
				)
			}
	}
}

private struct HighlightRequest: Equatable {
	let code: String
	let language: String
	let theme: String
	let fontSize: Double
}

@MainActor
private final class CodeHighlighter {
	static let shared = CodeHighlighter()

	private let highlighter: Highlightr?
	private let cache = NSCache<NSString, CacheEntry>()
	private var theme: String?

	private init() {
		highlighter = Highlightr()
		cache.countLimit = 50
		// Large diffs cost far more than tiny snippets; cap bytes, not just entries.
		cache.totalCostLimit = 8 * 1024 * 1024
	}

	func highlight(_ code: String, language: String, theme: String, fontSize: Double) async -> AttributedString {
		let key = "\(theme)|\(language)|\(code)" as NSString
		if let cached = cache.object(forKey: key) {
			return Self.styled(cached.value, fontSize: fontSize)
		}

		let highlighted: AttributedString
		if let highlighter {
			if !highlighter.supportedLanguages().contains(language) {
				print("WARNING: Language \(language) isn't supported, using auto detect")
			}

			if highlighter.availableThemes().contains(theme) {
				if self.theme != theme {
					highlighter.setTheme(to: theme)
					self.theme = theme
				}
			} else {
				print("WARNING: Theme \(theme) isn't supported")
			}

			if let attributed = highlighter.highlight(code, as: language) {
				highlighted = Self.styled(AttributedString(attributed), fontSize: fontSize)
			} else {
				highlighted = Self.styled(AttributedString(code), fontSize: fontSize)
			}
		} else {
			highlighted = Self.styled(AttributedString(code), fontSize: fontSize)
		}

		cache.setObject(CacheEntry(highlighted), forKey: key, cost: code.utf16.count)
		return highlighted
	}

	nonisolated static func styled(_ attributed: AttributedString, fontSize: Double) -> AttributedString {
		var result = attributed
		result.font = .custom("SF Mono", size: fontSize)
		result.inlinePresentationIntent = .code
		return result
	}

	private final class CacheEntry {
		let value: AttributedString

		init(_ value: AttributedString) {
			self.value = value
		}
	}
}

#Preview {
	CodeTextView(
		"let a = 2;\nconsole.log('Test', a);\n\nfor (const b of c) {\n\tconsole.log(b);\n}\n",
		language: "javascript",
		colorScheme: .light,
		fontSize: 24
	)
}
