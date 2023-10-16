// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "LFDomain",
  platforms: [.iOS(.v15), .macOS(.v10_14)],
  products: [
    .library(
      name: "OnboardingDomain",
      targets: ["OnboardingDomain"]),
    .library(
      name: "AccountDomain",
      targets: ["AccountDomain"]),
    .library(
      name: "NetSpendDomain",
      targets: ["NetSpendDomain"]),
    .library(
      name: "RewardDomain",
      targets: ["RewardDomain"]),
    .library(
      name: "ZerohashDomain",
      targets: ["ZerohashDomain"]),
    .library(
      name: "DevicesDomain",
      targets: ["DevicesDomain"]),
    .library(
      name: "CryptoChartDomain",
      targets: ["CryptoChartDomain"]),
    .library(
      name: "DomainDataMocks",
      targets: ["DomainDataMocks"])
  ],
  dependencies: [
    .package(name: "LFUtilities", path: "../LFUtilities"),
    .package(name: "TestHelpers", path: "../TestHelpers")
  ],
  targets: [
    .target(
      name: "OnboardingDomain",
      dependencies: []),
    .target(
      name: "AccountDomain",
      dependencies: [
        "NetSpendDomain", "LFUtilities"
      ]
    ),
    .target(
      name: "NetSpendDomain",
      dependencies: []
    ),
    .target(
      name: "RewardDomain",
      dependencies: []
    ),
    .target(
      name: "ZerohashDomain",
      dependencies: ["AccountDomain"]
    ),
    .target(
      name: "DevicesDomain",
      dependencies: []
    ),
    .target(
      name: "CryptoChartDomain",
      dependencies: []
    ),
    .target(
      name: "DomainDataMocks",
      dependencies: [
        "AccountDomain", "CryptoChartDomain", "DevicesDomain", "ZerohashDomain", "OnboardingDomain",
      ]
    ),
    .testTarget(
      name: "OnboardingDomainTests",
      dependencies: ["OnboardingDomain", "TestHelpers", "DomainDataMocks"])
  ]
)
