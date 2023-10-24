// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "CommonUX",
	platforms: [.macOS(.v10_13), .tvOS(.v13), .iOS(.v14)],
	products: [
		.library(name: "CommonUX", targets: [
			"CommonUX",
			"UXKit",
		]),
	],
	targets: [
		.target(name: "CommonUX", dependencies: ["UXKit"]),
		.target(name: "UXKit"),
	]
)
