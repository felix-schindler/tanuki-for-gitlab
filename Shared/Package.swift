// swift-tools-version: 6.1
import PackageDescription

let package = Package(
	name: "TanukiShared",
	platforms: [.iOS(.v18), .watchOS(.v11)],
	products: [
		.library(name: "TanukiShared", targets: ["TanukiShared"])
	],
	dependencies: [
		.package(
			url: "https://github.com/lorenzofiamingo/swiftui-cached-async-image",
			exact: "2.1.1"
		)
	],
	targets: [
		.target(
			name: "TanukiShared",
			dependencies: [
				.product(name: "CachedAsyncImage", package: "swiftui-cached-async-image")
			],
			resources: [.process("Resources")]
		)
	]
)
