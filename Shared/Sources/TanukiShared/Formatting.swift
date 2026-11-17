//
//  Formatting.swift
//  TanukiShared
//

import Foundation

// MARK: - Collection helpers
extension Array {
	public var isNotEmpty: Bool {
		return !self.isEmpty
	}
}

extension Set {
	public var isNotEmpty: Bool {
		return !self.isEmpty
	}
}

// MARK: - String helpers
extension String {
	public var isNotEmpty: Bool {
		return !self.isEmpty
	}

	public func emojized() -> String {
		return EmojiHelper.emojizedStringWithString(text: self)
	}
}

// MARK: - Date helpers
extension Date {
	// `ISO8601DateFormatter` is thread-safe once configured, so two shared instances are safe to read.
	private nonisolated(unsafe) static let isoWithFractional: ISO8601DateFormatter = {
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
		return formatter
	}()

	private nonisolated(unsafe) static let isoWithoutFractional: ISO8601DateFormatter = {
		ISO8601DateFormatter()
	}()

	public static func fromToString(
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

	public func toString(
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
	fileprivate var dateStyle: Date.FormatStyle.DateStyle? {
		switch self {
		case .none: nil
		case .short: .numeric
		case .medium: .abbreviated
		case .long: .long
		case .full: .complete
		@unknown default: .abbreviated
		}
	}

	fileprivate var timeStyle: Date.FormatStyle.TimeStyle? {
		switch self {
		case .none: nil
		case .short: .shortened
		case .medium, .long: .standard
		case .full: .complete
		@unknown default: .standard
		}
	}
}
