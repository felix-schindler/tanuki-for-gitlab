//
//  ByteFormatter.swift
//  Tanuki
//
//  Created by Felix Schindler on 12.11.26.
//

import Foundation

@MainActor
class ByteFormatter {
	static let shared = ByteFormatter()
	private let formatter: ByteCountFormatter

	private init() {
		self.formatter = ByteCountFormatter()
		self.formatter.countStyle = .file
		self.formatter.includesUnit = true
		self.formatter.isAdaptive = true
	}

	public func format(_ bytes: Int64) -> String {
		formatter.string(fromByteCount: bytes)
	}
}
