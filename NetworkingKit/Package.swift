// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NetworkingKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "NetworkingKit",
            targets: ["NetworkingKit"]
        )
    ],
    targets: [
        .target(
            name: "NetworkingKit",
            path: "Sources/NetworkingKit"
        ),
        .testTarget(
            name: "NetworkingKitTests",
            dependencies: ["NetworkingKit"],
            path: "Tests/NetworkingKitTests"
        )
    ]
)
