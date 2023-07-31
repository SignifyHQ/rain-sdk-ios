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
      name: "DataUtilities",
      targets: ["DataUtilities"]),
    .library(
      name: "AuthorizationManager",
      targets: ["AuthorizationManager"]),
    .library(
      name: "NetSpendData",
      targets: ["NetSpendData"]),
    .library(
      name: "CardData",
      targets: ["CardData"]),
    .library(
      name: "AccountData",
      targets: ["AccountData"])
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
        "DataUtilities", "LFNetwork", "AuthorizationManager", "Factory",
        .product(name: "OnboardingDomain", package: "LFDomain")
      ]
    ),
    .target(
      name: "DataUtilities",
      dependencies: ["LFNetwork"]),
    .target(
      name: "AuthorizationManager",
      dependencies: [
        "DataUtilities", "LFUtilities", "Factory",
        .product(name: "OnboardingDomain", package: "LFDomain")
      ]
    ),
    .target(
      name: "NetSpendData",
      dependencies: [
        "LFNetwork", "LFServices", "DataUtilities", "LFUtilities", "Factory", "AuthorizationManager"
      ]
    ),
    .target(
      name: "CardData",
      dependencies: [
        "DataUtilities", "LFNetwork", "Factory", "AuthorizationManager",
        .product(name: "CardDomain", package: "LFDomain"),
        .product(name: "AccountDomain", package: "LFDomain")
      ]
    ),
    .target(
      name: "AccountData",
      dependencies: [
        "DataUtilities", "LFNetwork", "Factory", "AuthorizationManager",
        .product(name: "AccountDomain", package: "LFDomain")
      ]
    ),
    .testTarget(
      name: "OnboardingDataTests",
      dependencies: ["OnboardingData"])
  ]
)
