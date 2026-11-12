//
//  Utils.swift
//  Tanuki (GitLab)
//
//  Created by Felix Schindler on 31.10.21.
//  Rewritten by Felix Schindler on 26.02.24.
//

import Foundation
import GitLabAPI
import SwiftUI
import TanukiEmoji

// MARK: - Cache helpers
enum FileCache {
	private static var root: URL {
		FileManager.default.temporaryDirectory
			.appendingPathComponent("tanuki-files", isDirectory: true)
	}

	/// A fresh, empty destination for one downloaded file.
	static func destination(for fileName: String) -> URL {
		root
			.appendingPathComponent(UUID().uuidString, isDirectory: true)
			.appendingPathComponent(fileName)
	}

	static func purge() {
		let staleBefore = Date().addingTimeInterval(-24 * 60 * 60)

		guard
			let entries = try? FileManager.default.contentsOfDirectory(
				at: root,
				includingPropertiesForKeys: [.contentModificationDateKey]
			)
		else {
			return
		}

		for entry in entries {
			let modified = try? entry.resourceValues(forKeys: [.contentModificationDateKey])
				.contentModificationDate
			if let modified, modified < staleBefore {
				try? FileManager.default.removeItem(at: entry)
			}
		}
	}

	/// Total bytes currently on disk. Purges stale entries first so the number is honest.
	static func size() -> Int64 {
		purge()

		guard
			let enumerator = FileManager.default.enumerator(
				at: root,
				includingPropertiesForKeys: [.fileSizeKey]
			)
		else {
			return 0
		}

		return enumerator.reduce(into: 0) { total, item in
			guard let url = item as? URL else { return }
			total += url.fileSize()
		}
	}

	static func clear() {
		try? FileManager.default.removeItem(at: root)
	}
}

// MARK: - Load helpers
extension View {
	/// Runs `action` immediately, then again 300 ms after `value` stops changing.
	/// Replaces the `.task { load() }` + `.onChange(of: value) { load() }` pair.
	func debouncedLoad<Value: Equatable>(_ value: Value, action: @escaping () async -> Void) -> some View {
		modifier(DebouncedLoad(value: value, action: action))
	}
}

private struct DebouncedLoad<Value: Equatable>: ViewModifier {
	let value: Value
	let action: () async -> Void

	@State
	private var hasLoaded = false

	func body(content: Content) -> some View {
		content.task(id: value) {
			if hasLoaded {
				do {
					try await Task.sleep(for: .milliseconds(300))
				} catch {
					return
				}
			} else {
				hasLoaded = true
			}
			await action()
		}
	}
}

// MARK: - Array helpers
extension Array {
	var isNotEmpty: Bool {
		return !self.isEmpty
	}
}

// MARK: - Set helpers
extension Set {
	var isNotEmpty: Bool {
		return !self.isEmpty
	}
}

// MARK: - String helpers
extension String {
	var isNotEmpty: Bool {
		return !self.isEmpty
	}

	func emojized() -> String {
		return EmojiHelper.emojizedStringWithString(text: self)
	}

	/// Writes the string to clipboard
	func copyToClipboard() {
		UIPasteboard.general.string = self
	}
}

extension GitLabAPI.ID {
	func toIntId() -> Int? {
		return Int(self.split(separator: "/").last ?? "")
	}

	func toStringId() -> String? {
		if let last = self.split(separator: "/").last {
			return String(last)
		}

		return nil
	}
}

// MARK: - URL helpers
extension URL {
	func fileSize() -> Int64 {
		guard let values = try? resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey]),
			values.isDirectory != true
		else {
			return 0
		}
		return Int64(values.fileSize ?? 0)
	}

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

// MARK: - Date helpers
extension Foundation.Date {
	@MainActor
	private static let isoWithFractional: ISO8601DateFormatter = {
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
		return formatter
	}()

	@MainActor
	private static let isoWithoutFractional: ISO8601DateFormatter = {
		ISO8601DateFormatter()
	}()

	@MainActor
	static func fromToString(
		_ date: String, dateStyle: DateFormatter.Style = .medium,
		timeStyle: DateFormatter.Style = .none
	) -> String {
		let dateObj =
			isoWithFractional.date(from: date)
			?? isoWithoutFractional.date(from: date)
		if let dateObj {
			return dateObj.toString(dateStyle, timeStyle: timeStyle)
		} else {
			return date
		}
	}

	func toString(
		_ dateStyle: DateFormatter.Style = .medium,
		timeStyle: DateFormatter.Style = .none
	) -> String {
		formatted(
			date: dateStyle.dateStyle ?? .omitted,
			time: timeStyle.timeStyle ?? .omitted
		)
	}
}

extension DateFormatter.Style {
	fileprivate var dateStyle: Foundation.Date.FormatStyle.DateStyle? {
		switch self {
		case .none: nil
		case .short: .numeric
		case .medium: .abbreviated
		case .long: .long
		case .full: .complete
		@unknown default: .abbreviated
		}
	}

	fileprivate var timeStyle: Foundation.Date.FormatStyle.TimeStyle? {
		switch self {
		case .none: nil
		case .short: .shortened
		case .medium, .long: .standard
		case .full: .complete
		@unknown default: .standard
		}
	}
}
