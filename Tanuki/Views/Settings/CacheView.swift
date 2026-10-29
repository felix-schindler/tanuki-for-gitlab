//
//  SettingsView.swift
//  Tanuki
//
//  Created by Felix Schindler on 03.10.25.
//

import SwiftUI

struct CacheView: View {
	private let formatter: ByteCountFormatter

	@State private var urlMemoryUsage = URLCache.shared.currentMemoryUsage
	@State private var urlDiskUsage = URLCache.shared.currentDiskUsage

	@State private var avatarMemoryUsage = URLCache.avatar.currentMemoryUsage
	@State private var avatarDiskUsage = URLCache.avatar.currentDiskUsage

	public init() {
		self.formatter = ByteCountFormatter()
		self.formatter.allowedUnits = [.useKB, .useMB, .useGB]
		self.formatter.countStyle = .file
	}

	private func formatBytes(_ bytes: Int) -> String {
		return formatter.string(fromByteCount: Int64(bytes))
	}

	public var body: some View {
		Form {
			Section("URL cache") {
				Text("In memory: \(formatBytes(urlMemoryUsage))")
				Text("On disk: \(formatBytes(urlDiskUsage))")
				Button("Clear cache", systemImage: "trash", role: .destructive) {
					URLCache.shared.removeAllCachedResponses()
					urlMemoryUsage = URLCache.shared.currentMemoryUsage
					urlDiskUsage = URLCache.shared.currentDiskUsage
				}
			}

			Section("Avatar cache") {
				Text("In memory \(formatBytes(avatarMemoryUsage))")
				Text("On disk \(formatBytes(avatarDiskUsage))")

				Button("Clear cache", systemImage: "trash", role: .destructive) {
					URLCache.avatar.removeAllCachedResponses()
					avatarMemoryUsage = URLCache.avatar.currentMemoryUsage
					avatarDiskUsage = URLCache.avatar.currentDiskUsage
				}
			}

			Section("File cache") {
				Text("Downloaded files: \(formatBytes(Int(FileCache.size())))")

				Button("Clear cache", systemImage: "trash", role: .destructive) {
					FileCache.clear()
					Notify.status(.success, "Cleared file cache", systemImage: "checkmark")
				}
			}

			Section("GraphQL cache") {
				Text(
					"Due to apollo-ios limitations, the actual size of the cache is unknown. If you feel this app is taking up too much storage, consider clearing this cache."
				)
				AsyncButton("Clear cache", systemImage: "trash", role: .destructive) {
					do {
						try await Network.shared.apollo.store.clearCache()
						Notify.status(.success, "Cleared cache", systemImage: "checkmark")
					} catch let error {
						Notify.status(
							.error, "Failed to clear cache", error.localizedDescription,
							systemImage: "xmark")
					}
				}
			}
		}.navigationTitle("Caches")
	}
}

#Preview {
	SettingsView()
}
