// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LFAuthentication",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "LFAuthentication",
            targets: ["LFAuthentication"]),
        .library(
          name: "BiometricsManager",
          targets: ["BiometricsManager"])
    ],
    dependencies: [
      .package(name: "LFData", path: "../LFData"),
      .package(name: "LFDomain", path: "../LFDomain"),
      .package(name: "LFUtilities", path: "../LFUtilities"),
      .package(name: "LFStyleGuide", path: "../LFStyleGuide"),
      .package(name: "LFLocalizable", path: "../LFLocalizable"),
      .package(name: "TestHelpers", path: "../TestHelpers"),
      .package(url: "https://github.com/hmlongco/Factory", from: "2.3.1")
    ],
    targets: [
        .target(
            name: "LFAuthentication",
            dependencies: [
              .product(name: "AccountData", package: "LFData"),
              .product(name: "AccountDomain", package: "LFDomain"),
              "LFUtilities",
              "LFStyleGuide",
              "LFLocalizable"
            ]
        ),
        .target(
          name: "BiometricsManager",
          dependencies: [
            "Factory", "LFLocalizable"
          ]
        ),
        .testTarget(
            name: "CreatePasswordViewModelTests",
            dependencies: [
              "LFAuthentication",
              "TestHelpers"
            ]
        )
    ]
)
