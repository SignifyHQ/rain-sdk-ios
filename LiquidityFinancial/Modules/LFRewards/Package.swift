// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LFRewards",
    platforms: [.iOS(.v15), .macOS(.v10_14)],
    products: [
        .library(
            name: "LFRewards",
            targets: ["LFRewards"]),
        .library(
          name: "RewardComponents",
          targets: ["RewardComponents"])
    ],
    dependencies: [
      .package(url: "https://github.com/hmlongco/Factory", from: "2.3.1"),
      .package(name: "LFUtilities", path: "../LFUtilities"),
      .package(name: "LFStyleGuide", path: "../LFStyleGuide"),
      .package(name: "LFDomain", path: "../LFDomain"),
      .package(name: "LFData", path: "../LFData"),
      .package(name: "LFLocalizable", path: "../LFLocalizable"),
      .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", from: "6.6.2")
    ],
    targets: [
        .target(
            name: "LFRewards",
            dependencies: [
              "LFUtilities", "LFStyleGuide", "LFLocalizable", "Factory", "RewardComponents",
              .product(name: "NetSpendData", package: "LFData"),
              .product(name: "RewardData", package: "LFData"),
              .product(name: "RewardDomain", package: "LFDomain")
            ],
            resources: [
              .process("ZResources")
            ],
            plugins: [
              .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin")
            ]
        ),
        .target(
          name: "RewardComponents",
          dependencies: [
            "LFUtilities", "LFStyleGuide", "LFLocalizable"
          ],
          resources: [
            .process("ZResources")
          ],
          plugins: [
            .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin")
          ]
        ),
        .testTarget(
            name: "LFRewardsTests",
            dependencies: ["LFRewards"])
    ]
)
