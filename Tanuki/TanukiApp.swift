//
//  TanukiApp.swift (GitLabApp.swift)
//  Tanuki (GitLab)
//
//  Created by Felix Schindler on 30.10.21.
//  Rewritten by Felix Schindler on 26.02.24.
//

import OSLog
import SwiftUI
import UIKit
import WebKit

let logger: Logger = Logger(subsystem: "de.schindlerfelix.GitLab", category: "Tanuki")

/// Sidebar entries on iPad. Settings has no tab on iPhone; it is reached from
/// the profile toolbar there.
enum PadTab: String, CaseIterable {
	case home, todos, explore, profile, settings
}

@main
struct TanukiApp: App {
	@StateObject
	private var sessionStore = SessionStore.shared

	@Environment(\.scenePhase)
	private var scenePhase

	@AppStorage(SettingsKey.appearance)
	private var appearance = ""

	@AppStorage(SettingsKey.padTab)
	private var padTab: PadTab?

	init() {
		InstanceManager.migrate()
		WatchSync.shared.activate()
		// Downloads are kept for a day, but only purged on a finished download or
		// when Settings is opened. Do it at launch, off the main thread.
		Task.detached(priority: .utility) {
			FileCache.purge()
		}
	}

	private func restorePersistedCookies() {
		let webStore = WKWebsiteDataStore.default().httpCookieStore
		for cookie in PersistedCookies.loadCookies() {
			webStore.setCookie(cookie)
			HTTPCookieStorage.shared.setCookie(cookie)
		}
	}

	private var colorScheme: ColorScheme? {
		switch appearance {
		case "light":
			.light
		case "dark":
			.dark
		default:
			nil
		}
	}

	public var body: some Scene {
		WindowGroup {
			main
				.preferredColorScheme(colorScheme)
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
		SwiftUI.Group {
			if UIDevice.current.userInterfaceIdiom == .pad {
				padView
			} else {
				phoneView
			}
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

	private var phoneView: some View {
		TabView {
			HomeView()
				.tabItem {
					Label("Home", systemImage: Icons.home.rawValue)
				}.tag(0)
			NavigationStack {
				CurrentUserTodosLoader()
			}.tabItem {
				Label("Todos", systemImage: Icons.todos.rawValue)
			}.tag(1)
			NavigationStack {
				ExploreView()
			}.tabItem {
				Label("Explore", systemImage: Icons.explore.rawValue)
			}.tag(2)
			NavigationStack {
				CurrentUserLoader()
			}.tabItem {
				Label("Profile", systemImage: Icons.users.rawValue)
			}.tag(3)
		}
	}

	private var padView: some View {
		NavigationSplitView {
			List(selection: $padTab) {
				Label("Home", systemImage: Icons.home.rawValue)
					.tag(PadTab.home)
				Label("Todos", systemImage: Icons.todos.rawValue)
					.tag(PadTab.todos)
				Label("Explore", systemImage: Icons.explore.rawValue)
					.tag(PadTab.explore)
				Label("Profile", systemImage: Icons.users.rawValue)
					.tag(PadTab.profile)
				Label("Settings", systemImage: Icons.settings.rawValue)
					.tag(PadTab.settings)
			}
			.listStyle(.sidebar)
			.navigationTitle("Tanuki")
		} detail: {
			if let padTab {
				padDetail(for: padTab)
			} else {
				padWelcome
			}
		}
	}

	@ViewBuilder
	private func padDetail(for tab: PadTab) -> some View {
		if tab == .home {
			// HomeView brings its own NavigationStack (it hosts the Jump paths).
			HomeView()
		} else {
			NavigationStack {
				switch tab {
				case .todos:
					CurrentUserTodosLoader()
				case .explore:
					ExploreView()
				case .profile:
					CurrentUserLoader()
				case .settings:
					SettingsView()
				case .home:
					EmptyView()
				}
			}
		}
	}

	private var padWelcome: some View {
		VStack(spacing: 12) {
			Image(systemName: Icons.home.rawValue)
				.font(.system(size: 44))
				.foregroundStyle(.secondary)
			Text("Welcome to Tanuki")
				.font(.title2.bold())
			Text("Choose a section in the sidebar.")
				.foregroundStyle(.secondary)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}
