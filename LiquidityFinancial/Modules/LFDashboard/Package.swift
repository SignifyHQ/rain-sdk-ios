// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "LFDashboard",
  platforms: [.iOS(.v15)],
  products: [
    .library(
      name: "LFDashboard",
      targets: ["LFDashboard"]),
    .library(
      name: "LFRewardDashboard",
      targets: ["LFRewardDashboard"]),
    .library(
      name: "BaseDashboard",
      targets: ["BaseDashboard"])
  ],
  dependencies: [
    .package(name: "LFUtilities", path: "../LFUtilities"),
    .package(name: "LFStyleGuide", path: "../LFStyleGuide"),
    .package(name: "LFLocalizable", path: "../LFLocalizable"),
    .package(name: "LFServices", path: "../LFServices"),
    .package(name: "LFCard", path: "../LFCard"),
    .package(name: "LFBank", path: "../LFBank"),
    .package(name: "LFTransaction", path: "../LFTransaction"),
    .package(name: "LFWalletAddress", path: "../LFWalletAddress"),
    .package(name: "LFCryptoChart", path: "../LFCryptoChart"),
    .package(name: "LFData", path: "../LFData"),
    .package(name: "LFNetwork", path: "../LFNetwork"),
    .package(name: "LFRewards", path: "../LFRewards"),
    .package(name: "LFAccountOnboarding", path: "../LFAccountOnboarding"),
    .package(url: "https://github.com/twostraws/CodeScanner", from: "2.0.0"),
    .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", from: "6.6.2")
  ],
  targets: [
    .target(
      name: "BaseDashboard",
      dependencies: [
        "LFUtilities", "LFServices", "LFAccountOnboarding",
        .product(name: "LFBaseBank", package: "LFBank"),
        .product(name: "OnboardingData", package: "LFData"),
        .product(name: "NetSpendData", package: "LFData"),
        .product(name: "ZerohashData", package: "LFData"),
        .product(name: "DevicesData", package: "LFData"),
        .product(name: "AuthorizationManager", package: "LFNetwork"),
        .product(name: "LFNetSpendCard", package: "LFCard"),
        .product(name: "LFSolidCard", package: "LFCard")
      ]
    ),
    .target(
      name: "LFDashboard",
      dependencies: [
        "LFUtilities", "LFStyleGuide", "LFLocalizable", "LFServices", "BaseDashboard",
        "LFBank", "LFTransaction", "LFCryptoChart", "CodeScanner", "LFWalletAddress",
        .product(name: "OnboardingData", package: "LFData"),
        .product(name: "NetSpendData", package: "LFData"),
        .product(name: "ZerohashData", package: "LFData"),
        .product(name: "DevicesData", package: "LFData"),
        .product(name: "AuthorizationManager", package: "LFNetwork"),
        .product(name: "LFNetSpendCard", package: "LFCard")
      ]
    ),
    .target(
      name: "LFRewardDashboard",
      dependencies: [
        "LFUtilities", "LFStyleGuide", "LFLocalizable", "LFServices", "LFTransaction", "CodeScanner", "LFRewards", "BaseDashboard",
        .product(name: "LFBank", package: "LFBank"),
        .product(name: "OnboardingData", package: "LFData"),
        .product(name: "NetSpendData", package: "LFData"),
        .product(name: "ZerohashData", package: "LFData"),
        .product(name: "DevicesData", package: "LFData"),
        .product(name: "AuthorizationManager", package: "LFNetwork"),
        .product(name: "LFSolidCard", package: "LFCard")
      ],
      resources: [
        .process("ZResources")
      ],
      plugins: [
        .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin")
      ]
    ),
    .testTarget(
      name: "LFDashboardTests",
      dependencies: ["LFDashboard"])
  ]
)
