// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SamuraiLogging",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "SamuraiLogging",
            targets: ["SamuraiLogging"]
        )
    ],
    targets: [
        .target(
            name: "SamuraiLogging"
        ),
        .testTarget(
            name: "SamuraiLoggingTests",
            dependencies: ["SamuraiLogging"]
        )
    ]
)
