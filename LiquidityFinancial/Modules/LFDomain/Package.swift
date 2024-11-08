// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "LFDomain",
  platforms: [.iOS(.v16)],
  products: [
    .library(
      name: "OnboardingDomain",
      targets: ["OnboardingDomain"]),
    .library(
      name: "AccountDomain",
      targets: ["AccountDomain"]),
    .library(
      name: "NetspendDomain",
      targets: ["NetspendDomain"]),
    .library(
      name: "RewardDomain",
      targets: ["RewardDomain"]),
    .library(
      name: "DevicesDomain",
      targets: ["DevicesDomain"]),
    .library(
      name: "FeatureFlagDomain",
      targets: ["FeatureFlagDomain"]),
    .library(
      name: "CryptoChartDomain",
      targets: ["CryptoChartDomain"]),
    .library(
      name: "RainDomain",
      targets: ["RainDomain"]),
    .library(
      name: "PortalDomain",
      targets: ["PortalDomain"]),
    .library(
      name: "DomainTestHelpers",
      targets: ["DomainTestHelpers"])
  ],
  dependencies: [
    .package(name: "LFUtilities", path: "../LFUtilities"),
    .package(name: "TestHelpers", path: "../TestHelpers"),
    .package(name: "LFServices", path: "../LFServices"),
    .package(url: "https://github.com/krzysztofzablocki/Sourcery.git", from: "2.0.0")
  ],
  targets: [
    .target(
      name: "OnboardingDomain",
      dependencies: []),
    .target(
      name: "AccountDomain",
      dependencies: [
        "NetspendDomain", "LFUtilities", "RainDomain",
        .product(name: "AccountService", package: "LFServices")
      ]
    ),
    .target(
      name: "NetspendDomain",
      dependencies: []
    ),
    .target(
      name: "RewardDomain",
      dependencies: []
    ),
    .target(
      name: "DevicesDomain",
      dependencies: []
    ),
    .target(
      name: "FeatureFlagDomain",
      dependencies: []
    ),
    .target(
      name: "CryptoChartDomain",
      dependencies: []
    ),
    .target(
      name: "RainDomain",
      dependencies: [
      ]
    ),
    .target(
      name: "PortalDomain",
      dependencies: [
        .product(name: "Services", package: "LFServices")
      ]
    ),
    .target(
      name: "DomainTestHelpers",
      dependencies: [
        "AccountDomain", "CryptoChartDomain", "DevicesDomain", "OnboardingDomain", "NetspendDomain", "RainDomain", "PortalDomain"
      ]
    ),
    .testTarget(
      name: "OnboardingDomainTests",
      dependencies: ["OnboardingDomain", "TestHelpers", "DomainTestHelpers"]),
    .testTarget(
      name: "CryptoChartDomainTests",
      dependencies: ["CryptoChartDomain", "TestHelpers", "DomainTestHelpers"]),
    .testTarget(
      name: "NetSpendDomainTests",
      dependencies: ["NetspendDomain", "TestHelpers", "DomainTestHelpers"]),
  ]
)
