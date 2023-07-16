// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LFStyleGuide",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "LFStyleGuide",
            targets: ["LFStyleGuide"])
    ],
    dependencies: [
      .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", from: "6.6.2"),
      .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.2.0")
    ],
    targets: [
        .target(
            name: "LFStyleGuide",
            dependencies: [],
            resources: [
              .process("XResources")
            ],
            plugins: [
              .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin"),
              .plugin(name: "Lottie", package: "Lottie")
            ]
        ),
        .testTarget(
            name: "LFStyleGuideTests",
            dependencies: ["LFStyleGuide"])
    ]
)
