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
		// Plain text for the first frame; the task below replaces it once highlighted.
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

/// One `Highlightr` (and its JavaScript context) for the whole app, plus a result cache
/// so scrolling back over a diff doesn't highlight the same file again.
@MainActor
private final class CodeHighlighter {
	static let shared = CodeHighlighter()

	private let highlighter: Highlightr?
	private let cache = NSCache<NSString, CacheEntry>()
	private var theme: String?

	private init() {
		highlighter = Highlightr()
		cache.countLimit = 50
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

		cache.setObject(CacheEntry(highlighted), forKey: key)
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
