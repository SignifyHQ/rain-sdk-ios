// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "LFData",
  platforms: [.iOS(.v15)],
  products: [
    .library(
      name: "OnboardingData",
      targets: ["OnboardingData"]),
    .library(
      name: "NetSpendData",
      targets: ["NetSpendData"]),
    .library(
      name: "AccountData",
      targets: ["AccountData"]),
    .library(
      name: "RewardData",
      targets: ["RewardData"]),
    .library(
      name: "ZerohashData",
      targets: ["ZerohashData"]),
    .library(
      name: "DevicesData",
      targets: ["DevicesData"])
  ],
  dependencies: [
    .package(name: "LFDomain", path: "../LFDomain"),
    .package(name: "LFNetwork", path: "../LFNetwork"),
    .package(name: "LFUtilities", path: "../LFUtilities"),
    .package(name: "LFServices", path: "../LFServices"),
    .package(url: "https://github.com/hmlongco/Factory", from: "2.2.0")
  ],
  targets: [
    .target(
      name: "OnboardingData",
      dependencies: [
        "Factory",
        .product(name: "OnboardingDomain", package: "LFDomain"),
        .product(name: "NetworkUtilities", package: "LFNetwork"),
        .product(name: "CoreNetwork", package: "LFNetwork")
      ]
    ),
    .target(
      name: "NetSpendData",
      dependencies: [
        "LFServices", "LFUtilities", "Factory",
        .product(name: "NetSpendDomain", package: "LFDomain"),
        .product(name: "NetworkUtilities", package: "LFNetwork"),
        .product(name: "CoreNetwork", package: "LFNetwork")
      ]
    ),
    .target(
      name: "AccountData",
      dependencies: [
        "Factory", "OnboardingData", "LFUtilities",
        .product(name: "AccountDomain", package: "LFDomain"),
        .product(name: "NetworkUtilities", package: "LFNetwork"),
        .product(name: "CoreNetwork", package: "LFNetwork")
      ]
    ),
    .target(
      name: "RewardData",
      dependencies: [
        "Factory", "LFUtilities", "AccountData",
        .product(name: "RewardDomain", package: "LFDomain"),
        .product(name: "NetworkUtilities", package: "LFNetwork"),
        .product(name: "CoreNetwork", package: "LFNetwork")
      ]
    ),
    .target(
      name: "ZerohashData",
      dependencies: [
        "Factory", "LFUtilities", "AccountData",
        .product(name: "ZerohashDomain", package: "LFDomain"),
        .product(name: "NetworkUtilities", package: "LFNetwork"),
        .product(name: "CoreNetwork", package: "LFNetwork")
      ]
    ),
    .target(
      name: "DevicesData",
      dependencies: [
        "Factory",
        .product(name: "DevicesDomain", package: "LFDomain"),
        .product(name: "NetworkUtilities", package: "LFNetwork"),
        .product(name: "CoreNetwork", package: "LFNetwork")
      ]
    ),
    .testTarget(
      name: "OnboardingDataTests",
      dependencies: ["OnboardingData"])
  ]
)
