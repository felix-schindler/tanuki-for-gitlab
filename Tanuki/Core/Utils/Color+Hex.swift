//
//  Color+Hex.swift
//  Tanuki
//

import SwiftUI

extension Color {
	/// Parses `RRGGBB` or `RRGGBBAA`, with or without a leading `#`.
	init?(hex: String?) {
		guard let hex else { return nil }

		let digits = hex.replacingOccurrences(of: "#", with: "").uppercased()
		guard let value = UInt64(digits, radix: 16) else { return nil }

		switch digits.count {
		case 6:
			self.init(
				.sRGB,
				red: Double((value >> 16) & 0xFF) / 255,
				green: Double((value >> 8) & 0xFF) / 255,
				blue: Double(value & 0xFF) / 255
			)
		case 8:
			self.init(
				.sRGB,
				red: Double((value >> 24) & 0xFF) / 255,
				green: Double((value >> 16) & 0xFF) / 255,
				blue: Double((value >> 8) & 0xFF) / 255,
				opacity: Double(value & 0xFF) / 255
			)
		default:
			return nil
		}
	}

	/// The color as uppercase `RRGGBB`, or `nil` if it can't be read as RGB.
	var hex: String? {
		guard let components = UIColor(self).cgColor.components, components.count >= 2 else {
			return nil
		}

		// Grayscale colors have just two components: white and alpha.
		let red = components[0]
		let green = components.count >= 3 ? components[1] : components[0]
		let blue = components.count >= 3 ? components[2] : components[0]

		return String(
			format: "%02X%02X%02X",
			Self.rgbComponent(red),
			Self.rgbComponent(green),
			Self.rgbComponent(blue)
		)
	}

	private static func rgbComponent(_ value: CGFloat) -> Int {
		Int((min(max(value, 0), 1) * 255).rounded())
	}
}
