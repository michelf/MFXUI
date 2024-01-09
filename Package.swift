// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "MFXUI",
	platforms: [.macOS(.v10_13), .tvOS(.v13), .iOS(.v14)],
	products: [
		.library(name: "MFXUI", targets: [
			"MFXUI",
			"UXKit",
		]),
	],
	targets: [
		.target(name: "MFXUI", dependencies: ["UXKit"]),
		.target(name: "UXKit"),
	]
)
