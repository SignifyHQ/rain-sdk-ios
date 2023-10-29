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
      name: "NetspendDomain",
      targets: ["NetspendDomain"]),
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
      name: "SolidDomain",
      targets: ["SolidDomain"]),
    .library(
      name: "DomainTestHelpers",
      targets: ["DomainTestHelpers"])
  ],
  dependencies: [
    .package(name: "LFUtilities", path: "../LFUtilities"),
    .package(name: "TestHelpers", path: "../TestHelpers"),
    .package(url: "https://github.com/krzysztofzablocki/Sourcery.git", from: "2.0.0")
  ],
  targets: [
    .target(
      name: "OnboardingDomain",
      dependencies: []),
    .target(
      name: "AccountDomain",
      dependencies: [
        "NetspendDomain", "LFUtilities"
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
      name: "SolidDomain",
      dependencies: []
    ),
    .target(
      name: "DomainTestHelpers",
      dependencies: [
        "AccountDomain", "CryptoChartDomain", "DevicesDomain", "ZerohashDomain", "OnboardingDomain", "SolidDomain", "NetspendDomain"
      ]
    ),
    .testTarget(
      name: "DomainTests",
      dependencies: ["TestHelpers", "DomainTestHelpers"]),
    .testTarget(
      name: "OnboardingDomainTests",
      dependencies: ["OnboardingDomain", "TestHelpers", "DomainTestHelpers"]),
    .testTarget(
      name: "ZerohashDomainTests",
      dependencies: ["ZerohashDomain", "TestHelpers", "DomainTestHelpers"]),
    .testTarget(
      name: "CryptoChartDomainTests",
      dependencies: ["CryptoChartDomain", "TestHelpers", "DomainTestHelpers"]),
    .testTarget(
      name: "NetSpendDomainTests",
      dependencies: ["NetspendDomain", "TestHelpers", "DomainTestHelpers"]),
    .testTarget(
      name: "SolidDomainTests",
      dependencies: ["SolidDomain", "TestHelpers", "DomainTestHelpers"])
  ]
)
