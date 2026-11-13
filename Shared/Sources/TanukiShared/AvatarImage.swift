//
//  AvatarImage.swift
//  TanukiShared
//
//  Shared by the iOS app and the watch app.
//

import CachedAsyncImage
import Foundation
import SwiftUI

// MARK: - Cache

extension URLCache {
	public static let avatar: URLCache = {
		#if os(watchOS)
			let memoryCapacity = 20 * 1024 * 1024  // 20 MB in RAM
			let diskCapacity = 100 * 1024 * 1024  // 100 MB on disk
		#else
			let memoryCapacity = 100 * 1024 * 1024  // 100 MB in RAM
			let diskCapacity = 300 * 1024 * 1024  // 300 MB on disk
		#endif

		return URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity)
	}()
}

// MARK: - View

public enum AvatarSize {
	case tiny,
		small,
		medium,
		big
}

public struct AvatarImage: View {
	private let url: URL

	private let radius: CGFloat
	private let width: CGFloat
	private let height: CGFloat

	public init(
		_ url: URL, radius: CGFloat = 10, width: CGFloat = 50,
		height: CGFloat = 50
	) {
		self.url = url
		self.radius = radius
		self.width = width
		self.height = height
	}

	public init(_ url: URL, size: AvatarSize) {
		self.url = url

		switch size {
		case .tiny:
			self.radius = 5
			self.width = 17.5
			self.height = 17.5
		case .small:
			self.radius = 5
			self.width = 25
			self.height = 25
		case .medium:
			self.radius = 7.5
			self.width = 37.5
			self.height = 37.5
		case .big:
			self.radius = 10
			self.width = 50
			self.height = 50
		}
	}

	public var body: some View {
		CachedAsyncImage(url: self.url, urlCache: .avatar) { phase in
			switch phase {
			case .empty:
				ProgressView()
			case .success(let image):
				image
					.resizable()
					.scaledToFit()
					.cornerRadius(self.radius)
			case .failure:
				Image(systemName: "photo.trianglebadge.exclamationmark")
					.resizable()
					.scaledToFit()
			@unknown default:
				EmptyView()
			}
		}.frame(width: width, height: height, alignment: .leading)
	}
}
