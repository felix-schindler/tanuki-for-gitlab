//
//  AvatarImage.swift
//  GitLab
//
//  Created by Felix Schindler on 10.06.23.
//

import CachedAsyncImage
import SwiftUI

enum AvatarSize {
	case tiny,
		small,
		medium,
		big
}

struct AvatarImage: View {
	let url: URL

	let radius: CGFloat
	let width: CGFloat
	let height: CGFloat

	init(
		_ url: URL, radius: CGFloat = 10, width: CGFloat = 50,
		height: CGFloat = 50
	) {
		self.url = url
		self.radius = radius
		self.width = width
		self.height = height
	}

	init(_ url: URL, size: AvatarSize) {
		self.url = url

		switch size {
		case .tiny:
			radius = 5
			width = 17.5
			height = 17.5
		case .small:
			radius = 5
			width = 25
			height = 25
		case .medium:
			radius = 7.5
			width = 37.5
			height = 37.5
		default:
			radius = 10
			width = 50
			height = 50
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
					.cornerRadius(radius)
			case .failure:
				Image(systemName: "photo.trianglebadge.exclamationmark")
					.resizable()
					.scaledToFit()
			@unknown default:
				EmptyView()
			}
		}.frame(width: width, height: height, alignment: .leading)
			.id("\(API.host):\(url.absoluteString)")
	}
}

#Preview {
	VStack {
		AvatarImage(
			URL(
				string:
					"https://gitlab.com/uploads/-/system/project/avatar/33025310/Tanuki-200kb.png"
			)!, size: .tiny)
		AvatarImage(
			URL(
				string:
					"https://gitlab.com/uploads/-/system/project/avatar/33025310/Tanuki-200kb.png"
			)!, size: .small)
		AvatarImage(
			URL(
				string:
					"https://gitlab.com/uploads/-/system/project/avatar/33025310/Tanuki-200kb.png"
			)!, size: .medium)
		AvatarImage(
			URL(
				string:
					"https://gitlab.com/uploads/-/system/project/avatar/33025310/Tanuki-200kb.png"
			)!, size: .big)
		AvatarImage(URL(string: "https://schindlerfelix.de/favicon.ico")!)
		AvatarImage(
			URL(string: "https://gitlab.com/uploads/-/system/project/avatar/39986149/flexbase.png")!
		)
		AvatarImage(
			URL(
				string:
					"https://gitlab.com/uploads/-/system/user/avatar/9005085/avatar.png"
			)!)
	}
}
