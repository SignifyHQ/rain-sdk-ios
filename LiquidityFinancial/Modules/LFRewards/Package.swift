// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LFRewards",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "LFRewards",
            targets: ["LFRewards"]),
        .library(
          name: "PridcardRewards",
          targets: ["PridcardRewards"])
    ],
    dependencies: [
      .package(url: "https://github.com/hmlongco/Factory", from: "2.2.0"),
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
              "LFUtilities", "LFStyleGuide", "LFLocalizable", "Factory", "PridcardRewards",
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
          name: "PridcardRewards",
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
