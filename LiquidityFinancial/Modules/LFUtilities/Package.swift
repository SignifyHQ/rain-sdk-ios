// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LFUtilities",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "LFUtilities",
            targets: ["LFUtilities"])
    ],
    dependencies: [

    ],
    targets: [
        .target(
            name: "LFUtilities",
            dependencies: []),
        .testTarget(
            name: "LFUtilitiesTests",
            dependencies: ["LFUtilities"])
    ]
)
