// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SamuraiLoggingFirebaseCrashlytics",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
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
