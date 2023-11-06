// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "LFCard",
  platforms: [.iOS(.v15), .macOS(.v10_14)],
  products: [
    .library(
      name: "BaseCard",
      targets: ["BaseCard"]
    ),
    .library(
      name: "LFNetSpendCard",
      targets: ["LFNetSpendCard"]
    ),
    .library(
      name: "LFSolidCard",
      targets: ["LFSolidCard"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/hmlongco/Factory", from: "2.3.1"),
    .package(name: "LFDomain", path: "../LFDomain"),
    .package(name: "LFUtilities", path: "../LFUtilities"),
    .package(name: "LFStyleGuide", path: "../LFStyleGuide"),
    .package(name: "LFLocalizable", path: "../LFLocalizable"),
    .package(name: "LFServices", path: "../LFServices"),
    .package(name: "LFData", path: "../LFData"),
    .package(name: "LFRewards", path: "../LFRewards")
  ],
  targets: [
    .target(
      name: "BaseCard",
      dependencies: [
        "LFUtilities", "LFStyleGuide", "LFLocalizable", "Factory", "LFRewards",
        .product(name: "OnboardingData", package: "LFData"),
        .product(name: "NetSpendData", package: "LFData"),
        .product(name: "AccountData", package: "LFData"),
        .product(name: "RewardData", package: "LFData"),
        .product(name: "RewardDomain", package: "LFDomain"),
        .product(name: "Services", package: "LFServices"),
        .product(name: "NetspendDomain", package: "LFDomain")
      ]),
    .target(
      name: "LFNetSpendCard",
      dependencies: [
        "BaseCard", "LFUtilities", "LFStyleGuide", "LFLocalizable", "Factory", "LFRewards",
        .product(name: "OnboardingData", package: "LFData"),
        .product(name: "NetSpendData", package: "LFData"),
        .product(name: "AccountData", package: "LFData"),
        .product(name: "RewardData", package: "LFData"),
        .product(name: "RewardDomain", package: "LFDomain"),
        .product(name: "Services", package: "LFServices"),
        .product(name: "NetspendDomain", package: "LFDomain")
      ]),
    .target(
      name: "LFSolidCard",
      dependencies: [
        "BaseCard", "LFUtilities", "LFStyleGuide", "LFLocalizable", "Factory", "LFRewards",
        .product(name: "OnboardingData", package: "LFData"),
        .product(name: "NetSpendData", package: "LFData"),
        .product(name: "AccountData", package: "LFData"),
        .product(name: "RewardData", package: "LFData"),
        .product(name: "RewardDomain", package: "LFDomain"),
        .product(name: "Services", package: "LFServices"),
        .product(name: "NetspendDomain", package: "LFDomain")
      ]),
    .testTarget(
      name: "LFCardTests",
      dependencies: ["BaseCard", "LFNetSpendCard", "LFSolidCard"])
  ]
)
