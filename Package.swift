// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Components",
    platforms: [
        .iOS("18.0")
    ],
    products: [
        .library(
            name: "Components",
            targets: ["Components"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.0.0")
    ],
    targets: [
        .target(
            name: "Components",
            dependencies: [
                .product(name: "Kingfisher", package: "Kingfisher")
            ]
        ),
        .testTarget(
            name: "ComponentsTests",
            dependencies: ["Components"]
        )
    ]
)
