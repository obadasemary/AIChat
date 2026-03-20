// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SamuraiLoggingFirebaseCrashlytics",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SamuraiLoggingFirebaseCrashlytics",
            targets: ["SamuraiLoggingFirebaseCrashlytics"]
        ),
    ],
    dependencies: [
        .package(path: "../SamuraiLogging"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", "11.0.0"..<"12.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SamuraiLoggingFirebaseCrashlytics",
            dependencies: [
                .product(name: "SamuraiLogging", package: "SamuraiLogging"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk")
            ]
        ),
        .testTarget(
            name: "SamuraiLoggingFirebaseCrashlyticsTests",
            dependencies: ["SamuraiLoggingFirebaseCrashlytics"]
        ),
    ]
)
