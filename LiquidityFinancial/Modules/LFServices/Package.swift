// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LFServices",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "LFServices",
            targets: ["LFServices"])
    ],
    dependencies: [

    ],
    targets: [
        .target(
            name: "LFServices",
            dependencies: []),
        .testTarget(
            name: "LFServicesTests",
            dependencies: ["LFServices"])
    ]
)
