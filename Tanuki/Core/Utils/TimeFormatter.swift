//
//  TimeFormatter.swift
//  Tanuki
//
//  Created by Felix Schindler on 12.11.26.
//

import Foundation

@MainActor
class TimeFormatter {
	static let shared = TimeFormatter()
	private let formatter: DateComponentsFormatter

	private init() {
		self.formatter = DateComponentsFormatter()
		self.formatter.allowedUnits = [.hour, .minute, .second]
		self.formatter.unitsStyle = .abbreviated
		self.formatter.zeroFormattingBehavior = .dropTrailing
	}

	public func format(_ seconds: Int64) -> String {
		formatter.string(from: TimeInterval(seconds)) ?? "0s"
	}
}
