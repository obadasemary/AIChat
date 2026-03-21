// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SamuraiLoggingMixpanel",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SamuraiLoggingMixpanel",
            targets: ["SamuraiLoggingMixpanel"]
        ),
    ],
    dependencies: [
        .package(path: "../SamuraiLogging"),
        .package(url: "https://github.com/mixpanel/mixpanel-swift.git", "4.0.0"..<"5.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SamuraiLoggingMixpanel",
            dependencies: [
                .product(name: "SamuraiLogging", package: "SamuraiLogging"),
                .product(name: "Mixpanel", package: "mixpanel-swift")
            ]
        ),
        .testTarget(
            name: "SamuraiLoggingMixpanelTests",
            dependencies: ["SamuraiLoggingMixpanel"]
        ),
    ]
)
