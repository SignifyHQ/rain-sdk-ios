// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "LFDashboard",
  platforms: [.iOS(.v15)],
  products: [
    .library(
      name: "LFNetspendDashboard",
      targets: ["LFNetspendDashboard"]),
    .library(
      name: "LFRewardDashboard",
      targets: ["LFRewardDashboard"]),
    .library(
      name: "LFNoBankDashboard",
      targets: ["LFNoBankDashboard"]),
    .library(
      name: "DashboardComponents",
      targets: ["DashboardComponents"])
  ],
  dependencies: [
    .package(name: "LFUtilities", path: "../LFUtilities"),
    .package(name: "LFStyleGuide", path: "../LFStyleGuide"),
    .package(name: "LFLocalizable", path: "../LFLocalizable"),
    .package(name: "LFAccessibility", path: "../LFAccessibility"),
    .package(name: "LFServices", path: "../LFServices"),
    .package(name: "LFCard", path: "../LFCard"),
    .package(name: "LFBank", path: "../LFBank"),
    .package(name: "LFTransaction", path: "../LFTransaction"),
    .package(name: "LFWalletAddress", path: "../LFWalletAddress"),
    .package(name: "LFCryptoChart", path: "../LFCryptoChart"),
    .package(name: "LFData", path: "../LFData"),
    .package(name: "LFDomain", path: "../LFDomain"),
    .package(name: "LFNetwork", path: "../LFNetwork"),
    .package(name: "LFRewards", path: "../LFRewards"),
    .package(name: "LFOnboarding", path: "../LFOnboarding"),
    .package(name: "LFAuthentication", path: "../LFAuthentication"),
    .package(url: "https://github.com/twostraws/CodeScanner", from: "2.0.0"),
    .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", from: "6.6.2")
  ],
  targets: [
    .target(
      name: "DashboardComponents",
      dependencies: [
        "LFUtilities", "LFStyleGuide",
        .product(name: "Services", package: "LFServices"),
        .product(name: "ZerohashData", package: "LFData"),
        .product(name: "AccountData", package: "LFData"),
        .product(name: "AccountDomain", package: "LFDomain"),
        .product(name: "AccountService", package: "LFServices")
      ]
    ),
    .target(
      name: "LFNetspendDashboard",
      dependencies: [
        "LFUtilities", "LFStyleGuide", "LFLocalizable", "LFAccessibility", "DashboardComponents", "LFTransaction", "LFCryptoChart", "CodeScanner", "LFWalletAddress",
        .product(name: "OnboardingData", package: "LFData"),
        .product(name: "LFNetspendBank", package: "LFBank"),
        .product(name: "NetSpendData", package: "LFData"),
        .product(name: "ZerohashData", package: "LFData"),
        .product(name: "DevicesData", package: "LFData"),
        .product(name: "ExternalFundingData", package: "LFData"),
        .product(name: "AuthorizationManager", package: "LFNetwork"),
        .product(name: "Services", package: "LFServices"),
        .product(name: "LFNetSpendCard", package: "LFCard"),
        .product(name: "BiometricsManager", package: "LFAuthentication"),
        .product(name: "LFAuthentication", package: "LFAuthentication"),
        .product(name: "NetspendOnboarding", package: "LFOnboarding")
      ]
    ),
    .target(
      name: "LFRewardDashboard",
      dependencies: [
        "LFUtilities", "LFStyleGuide", "LFLocalizable", "LFAccessibility", "LFTransaction", "CodeScanner", "LFRewards", "DashboardComponents",
        .product(name: "LFSolidBank", package: "LFBank"),
        .product(name: "OnboardingData", package: "LFData"),
        .product(name: "DevicesData", package: "LFData"),
        .product(name: "AuthorizationManager", package: "LFNetwork"),
        .product(name: "LFSolidCard", package: "LFCard"),
        .product(name: "Services", package: "LFServices"),
        .product(name: "SolidOnboarding", package: "LFOnboarding"),
        .product(name: "BiometricsManager", package: "LFAuthentication"),
        .product(name: "LFAuthentication", package: "LFAuthentication")
      ],
      resources: [
        .process("ZResources")
      ],
      plugins: [
        .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin")
      ]
    ),
    .target(
      name: "LFNoBankDashboard",
      dependencies: [
        "LFUtilities", "LFStyleGuide", "LFLocalizable", "LFAccessibility", "DashboardComponents", "LFTransaction", "LFCryptoChart", "CodeScanner", "LFWalletAddress",
        .product(name: "OnboardingData", package: "LFData"),
        .product(name: "LFNetspendBank", package: "LFBank"),
        .product(name: "NetSpendData", package: "LFData"),
        .product(name: "ZerohashData", package: "LFData"),
        .product(name: "DevicesData", package: "LFData"),
        .product(name: "AuthorizationManager", package: "LFNetwork"),
        .product(name: "Services", package: "LFServices"),
        .product(name: "LFNetSpendCard", package: "LFCard"),
        .product(name: "BiometricsManager", package: "LFAuthentication"),
        .product(name: "NoBankOnboarding", package: "LFOnboarding"),
        .product(name: "LFAuthentication", package: "LFAuthentication")
      ]
    ),
    .testTarget(
      name: "LFDashboardTests",
      dependencies: ["LFNetspendDashboard"])
  ]
)
