// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LetSee",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Letsee-Core",
            targets: ["Letsee.Core"]),
		.library(
			name: "Letsee-Interceptor",
			targets: ["Letsee.Interceptor"]),
		.library(
			name: "Letsee-InAppView",
			targets: ["Letsee.InAppView"]),
		.library(
			name: "Letsee-MoyaPlugin",
			targets: ["Letsee.MoyaPlugin"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/httpswift/swifter.git", .upToNextMajor(from: "1.5.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Letsee.Core",
			dependencies: [.product(name: "Swifter", package: "Swifter")],
			path: "./Sources/LetSee/Core",
            resources: [.copy("Website")]),

		.target(name: "Letsee.Interceptor",
				dependencies: [.target(name: "Letsee.Core")], path: "./Sources/LetSee/Interceptor"),

		.target(name: "Letsee.InAppView",dependencies: [.target(name: "Letsee.Core"), .target(name: "Letsee.Interceptor")], path: "./Sources/LetSee/InAppView"),

		.target(name: "Letsee.MoyaPlugin", dependencies: [.target(name: "Letsee.Core"), .target(name: "Letsee.Interceptor")], path: "./Sources/LetSee/MoyaPlugin"),
        
        .testTarget(
            name: "LetSeeTests",
            dependencies: ["Letsee.Core", "Letsee.Interceptor", "Letsee.InAppView","Letsee.MoyaPlugin"]),
    ]
)
