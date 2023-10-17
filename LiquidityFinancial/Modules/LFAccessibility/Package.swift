// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LFAccessibility",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "LFAccessibility",
            targets: ["LFAccessibility"])
    ],
    dependencies: [
      .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", from: "6.6.2")
    ],
    targets: [
        .target(
            name: "LFAccessibility",
            dependencies: [],
            resources: [
              .process("Resources")
            ],
            plugins: [
              .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin")
            ])
    ]
)
