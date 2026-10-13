//
//  FailedView.swift
//  Tanuki
//
//  Created by Felix Schindler on 04.09.25.
//

import LucideSwift
import SwiftUI

struct FailedView: View {
	private let msg: String
	private let icon: LucideIconName

	init(_ error: Error) {
		self.icon = .triangleAlert
		self.msg = error.localizedDescription
	}

	init(
		_ message: String = "Failed to load. Please make sure you're connected to the internet.",
		icon: LucideIconName = .triangleAlert
	) {
		self.msg = message
		self.icon = icon
	}

	public var body: some View {
		NoContentView(msg, lucide: icon)
			.foregroundStyle(.red)
	}
}
