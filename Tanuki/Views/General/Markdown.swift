//
//  Markdown.swift
//  Tanuki
//
//  Created by Felix Schindler on 29.09.26.
//

import MarkdownView
import SwiftUI
import Textual

struct Markdown: View {
	private let content: String
	private let baseURL: URL?
	private let imageBaseURL: URL?

	@AppStorage(SettingsKey.supportHtmlInMarkdown)
	private var supportHTML = false

	init(_ content: String, baseURL: URL? = nil, imageBaseURL: URL? = nil) {
		self.content = content.emojized()
		self.baseURL = baseURL
		self.imageBaseURL = imageBaseURL
	}

	public var body: some View {
		if supportHTML {
			HTMLMarkdown(content, imageBaseURL: imageBaseURL)
		} else {
			StructuredText(markdown: content, baseURL: baseURL)
		}
	}
}

struct InlineMarkdown: View {
	private let content: String
	private let baseURL: URL?

	init(_ content: String, baseURL: URL? = nil) {
		self.content = content.emojized()
		self.baseURL = baseURL
	}

	public var body: some View {
		InlineText(markdown: content, baseURL: baseURL)
	}
}

private struct HTMLMarkdown: View {
	private let content: String
	private let imageBaseURL: URL?

	@State
	private var height: CGFloat = 1

	init(_ content: String, imageBaseURL: URL? = nil) {
		self.content = content
		self.imageBaseURL = imageBaseURL
	}

	private static let compactCSS =
		"body{margin:0 !important;padding:0 !important;}"
		+ ".container{padding-left:0 !important;padding-right:0 !important;}"
		+ "#contents>:first-child{margin-top:0 !important;}"
		+ "#contents>:last-child{margin-bottom:0 !important;}"

	public var body: some View {
		MarkdownUI(body: content.emojized(), css: Self.compactCSS, styled: true)
			.onRendered { renderedHeight in
				if renderedHeight > 0, abs(renderedHeight - height) > 1 {
					height = renderedHeight
				}
			}
			.frame(maxWidth: .infinity)
			.frame(height: height)
	}
}
