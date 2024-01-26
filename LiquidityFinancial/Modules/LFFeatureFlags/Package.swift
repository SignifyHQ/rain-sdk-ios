// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LFFeatureFlags",
    platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "LFFeatureFlags",
            targets: ["LFFeatureFlags"]
        )
    ],
    dependencies: [
      .package(url: "https://github.com/hmlongco/Factory", from: "2.3.1"),
      .package(name: "LFUtilities", path: "../LFUtilities"),
      .package(name: "LFStyleGuide", path: "../LFStyleGuide"),
      .package(name: "LFDomain", path: "../LFDomain"),
      .package(name: "LFData", path: "../LFData")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "LFFeatureFlags",
            dependencies: [
              "Factory", "LFUtilities", "LFStyleGuide",
              .product(name: "FeatureFlagData", package: "LFData"),
              .product(name: "FeatureFlagDomain", package: "LFDomain")
            ]
        ),
        .testTarget(
            name: "LFFeatureFlagsTests",
            dependencies: ["LFFeatureFlags"]
        )
    ]
)
