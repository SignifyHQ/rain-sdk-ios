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
      .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", from: "6.6.2")
    ],
    targets: [
        .target(
            name: "LFStyleGuide",
            dependencies: [],
            resources: [
              .process("Resources")
            ],
            plugins: [
              .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin")
            ]
        ),
        .testTarget(
            name: "LFStyleGuideTests",
            dependencies: ["LFStyleGuide"])
    ]
)
