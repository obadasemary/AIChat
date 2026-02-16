// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LoggingService",
    platforms: [
        .iOS(.v17)
    ],
    swiftLanguageModes: [.v5],
    products: [
        .library(name: "LoggingService", targets: ["LoggingService"]),
        .library(name: "LoggingServiceFirebase", targets: ["LoggingServiceFirebase"]),
        .library(name: "LoggingServiceMixpanel", targets: ["LoggingServiceMixpanel"])
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "11.0.0"),
        .package(url: "https://github.com/mixpanel/mixpanel-swift", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "LoggingService"
        ),
        .target(
            name: "LoggingServiceFirebase",
            dependencies: [
                "LoggingService",
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk")
            ]
        ),
        .target(
            name: "LoggingServiceMixpanel",
            dependencies: [
                "LoggingService",
                .product(name: "Mixpanel", package: "mixpanel-swift")
            ]
        ),
        .testTarget(
            name: "LoggingServiceTests",
            dependencies: ["LoggingService"]
        )
    ]
)
