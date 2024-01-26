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
      name: "FeatureFlagData",
      targets: ["FeatureFlagData"]),
    .library(
      name: "CryptoChartData",
      targets: ["CryptoChartData"]),
    .library(
      name: "ExternalFundingData",
      targets: ["ExternalFundingData"]),
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
    .package(url: "https://github.com/krzysztofzablocki/Sourcery.git", from: "2.0.0")
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
        "LFUtilities", "Factory",
        .product(name: "NetspendDomain", package: "LFDomain"),
        .product(name: "NetworkUtilities", package: "LFNetwork"),
        .product(name: "CoreNetwork", package: "LFNetwork"),
        .product(name: "AccountService", package: "LFServices"),
        .product(name: "BankService", package: "LFServices"),
        .product(name: "Services", package: "LFServices")
      ]
    ),
    .target(
      name: "SolidData",
      dependencies: [
        "LFUtilities", "Factory",
        .product(name: "NetspendDomain", package: "LFDomain"),
        .product(name: "SolidDomain", package: "LFDomain"),
        .product(name: "NetworkUtilities", package: "LFNetwork"),
        .product(name: "CoreNetwork", package: "LFNetwork"),
        .product(name: "AccountService", package: "LFServices"),
        .product(name: "BankService", package: "LFServices"),
        .product(name: "Services", package: "LFServices")
      ]
    ),
    .target(
      name: "ExternalFundingData",
      dependencies: [
        "Factory"
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
      name: "FeatureFlagData",
      dependencies: [
        "Factory",
        .product(name: "FeatureFlagDomain", package: "LFDomain"),
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
    .testTarget(
      name: "CryptoChartDataTests",
      dependencies: [
        "CryptoChartData", "DataTestHelpers", "TestHelpers",
        .product(name: "NetworkTestHelpers", package: "LFNetwork")
      ]
    ),
    .target(
      name: "DataTestHelpers",
      dependencies: [
        "OnboardingData", "NetSpendData", "AccountData", "RewardData", "ZerohashData", "DevicesData", "CryptoChartData", "SolidData",
        .product(name: "NetspendDomain", package: "LFDomain")
      ]
    ),
    .testTarget(
      name: "DevicesDataTests",
      dependencies: [
        "DevicesData", "DataTestHelpers",
        .product(name: "NetworkTestHelpers", package: "LFNetwork")
      ]
    ),
    .testTarget(
      name: "OnboardingDataTests",
      dependencies: [
        "OnboardingData", "DataTestHelpers", "TestHelpers",
        .product(name: "NetworkTestHelpers", package: "LFNetwork")
      ]
    ),
    .testTarget(
      name: "NetSpendDataTests",
      dependencies: [
        "NetSpendData", "DataTestHelpers", "TestHelpers",
        .product(name: "NetworkTestHelpers", package: "LFNetwork")
      ]
    ),
    .testTarget(
      name: "SolidDataTests",
      dependencies: [
        "SolidData", "DataTestHelpers", "TestHelpers",
        .product(name: "NetworkTestHelpers", package: "LFNetwork")
      ]
    ),
    .testTarget(
      name: "ZerohashDataTests",
      dependencies: [
        "ZerohashData", "DataTestHelpers", "TestHelpers",
        .product(name: "NetworkTestHelpers", package: "LFNetwork")
      ]
    )
  ]
)
