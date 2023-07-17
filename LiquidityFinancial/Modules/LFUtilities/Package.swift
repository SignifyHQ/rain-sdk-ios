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
      .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", .upToNextMajor(from: "2.0.0"))
    ],
    targets: [
        .target(
            name: "LFUtilities",
            dependencies: ["SwiftyBeaver"]),
        .testTarget(
            name: "LFUtilitiesTests",
            dependencies: ["LFUtilities"])
    ]
)
