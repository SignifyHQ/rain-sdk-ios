// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "LFData",
  platforms: [.iOS(.v15), .macOS(.v10_14)],
  products: [
    .library(
      name: "OnboardingData",
      targets: ["OnboardingData"]),
    .library(
      name: "NetSpendData",
      targets: ["NetSpendData"]),
    .library(
      name: "SolidData",
      targets: ["SolidData"]),
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
      targets: ["DevicesData"]),
    .library(
      name: "CryptoChartData",
      targets: ["CryptoChartData"]),
    .library(
      name: "DataTestHelpers",
      targets: ["DataTestHelpers"])
  ],
  dependencies: [
    .package(name: "LFDomain", path: "../LFDomain"),
    .package(name: "LFNetwork", path: "../LFNetwork"),
    .package(name: "LFUtilities", path: "../LFUtilities"),
    .package(name: "LFServices", path: "../LFServices"),
    .package(name: "TestHelpers", path: "../TestHelpers"),
    .package(url: "https://github.com/hmlongco/Factory", from: "2.3.1"),
    .package(url: "https://github.com/krzysztofzablocki/Sourcery.git", from: "2.0.0"),
    .package(url:  "https://github.com/Quick/Nimble.git", from: "12.0.0")
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
        .product(name: "BankDomain", package: "LFDomain"),
        .product(name: "NetworkUtilities", package: "LFNetwork"),
        .product(name: "CoreNetwork", package: "LFNetwork")
      ]
    ),
    .target(
      name: "SolidData",
      dependencies: [
        "LFServices", "LFUtilities", "Factory",
        .product(name: "BankDomain", package: "LFDomain"),
        .product(name: "NetworkUtilities", package: "LFNetwork"),
        .product(name: "CoreNetwork", package: "LFNetwork")
      ]
    ),
    .target(
      name: "AccountData",
      dependencies: [
        "Factory", "OnboardingData", "LFUtilities", "NetSpendData",
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
    .target(
      name: "CryptoChartData",
      dependencies: [
        "Factory", "LFUtilities",
        .product(name: "NetworkUtilities", package: "LFNetwork"),
        .product(name: "CoreNetwork", package: "LFNetwork"),
        .product(name: "CryptoChartDomain", package: "LFDomain")
      ]
    ),
    .target(
      name: "DataTestHelpers",
      dependencies: [
        "OnboardingData", "NetSpendData", "AccountData", "RewardData", "ZerohashData", "DevicesData", "CryptoChartData"
      ]
    ),
    .testTarget(
      name: "OnboardingDataTests",
      dependencies: [
        "OnboardingData", "DataTestHelpers", "TestHelpers", "Nimble",
        .product(name: "NetworkTestHelpers", package: "LFNetwork")
      ]
    )
  ]
)
