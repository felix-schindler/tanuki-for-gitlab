//
//  SessionStore.swift
//  Tanuki
//
//  Created by Felix Schindler on 28.04.26.
//

import SwiftUI
import TanukiShared

@MainActor
final class SessionStore: ObservableObject {
	static let shared = SessionStore()

	@Published
	private(set) var needsSetup: Bool

	private init() {
		needsSetup = Self.requiresSetup
	}

	func setNeedsSetup(_ value: Bool) {
		needsSetup = value
	}

	func refresh() {
		needsSetup = Self.requiresSetup
	}

	/// No instance, or an instance without a token, means the user still has to log in.
	private static var requiresSetup: Bool {
		InstanceManager.selected?.token.isEmpty ?? true
	}
}
