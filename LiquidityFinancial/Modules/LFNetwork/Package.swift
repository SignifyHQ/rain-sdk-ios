// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LFNetwork",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "LFNetwork",
            targets: ["LFNetwork"])
    ],
    dependencies: [

    ],
    targets: [
        .target(
            name: "LFNetwork",
            dependencies: [])
    ]
)
