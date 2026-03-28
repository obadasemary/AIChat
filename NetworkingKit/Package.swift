// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "NetworkingKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "NetworkingKit",
            targets: ["NetworkingKit"]
        )
    ],
    targets: [
        .target(
            name: "NetworkingKit"
        ),
        .testTarget(
            name: "NetworkingKitTests",
            dependencies: ["NetworkingKit"]
        )
    ]
)
