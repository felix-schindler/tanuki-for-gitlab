//
//  TanukiApp.swift (GitLabApp.swift)
//  Tanuki (GitLab)
//
//  Created by Felix Schindler on 30.10.21.
//  Rewritten by Felix Schindler on 26.02.24.
//

import OSLog
import SwiftUI
import WebKit

let logger: Logger = Logger(subsystem: "de.schindlerfelix.GitLab", category: "Tanuki")

@main
struct TanukiApp: App {
	@StateObject
	private var sessionStore = SessionStore.shared

	@Environment(\.scenePhase)
	private var scenePhase

	init() {
		InstanceManager.migrate()
		WatchSync.shared.activate()
	}

	private func restorePersistedCookies() {
		let webStore = WKWebsiteDataStore.default().httpCookieStore
		for cookie in PersistedCookies.loadCookies() {
			webStore.setCookie(cookie)
			HTTPCookieStorage.shared.setCookie(cookie)
		}
	}

	public var body: some Scene {
		WindowGroup {
			main
				.fullScreenCover(
					isPresented: Binding(
						get: { sessionStore.needsSetup },
						set: { newValue in
							if !newValue {
								sessionStore.setNeedsSetup(false)
							}
						}
					)
				) {
					SetupView()
				}
		}
	}

	public var main: some View {
		TabView {
			HomeView()
				.tabItem {
					Label("Home", lucide: .house)
				}.tag(0)
			NavigationStack {
				CurrentUserTodosLoader()
			}.tabItem {
				Label("Todos", lucide: .squareCheckBig)
			}.tag(1)
			NavigationStack {
				ExploreView()
			}.tabItem {
				Label("Explore", lucide: .sparkles)
			}.tag(2)
			NavigationStack {
				CurrentUserLoader()
			}.tabItem {
				Label("Profile", lucide: .user)
			}.tag(3)
		}.task {
			sessionStore.refresh()
			restorePersistedCookies()
			await Auth.ensureValidToken()
		}.onChange(of: scenePhase) { _, newPhase in
			if newPhase == .active {
				Task {
					await Auth.ensureValidToken()
				}
			}
		}
	}
}
