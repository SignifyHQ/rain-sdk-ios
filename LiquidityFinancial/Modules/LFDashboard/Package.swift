// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "LFDashboard",
  platforms: [.iOS(.v15), .macOS(.v10_14)],
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
      name: "BaseDashboard",
      dependencies: [
        "LFUtilities",
        .product(name: "Services", package: "LFServices"),
        .product(name: "LFBaseBank", package: "LFBank"),
        .product(name: "OnboardingData", package: "LFData"),
        .product(name: "NetSpendData", package: "LFData"),
        .product(name: "SolidData", package: "LFData"),
        .product(name: "ZerohashData", package: "LFData"),
        .product(name: "DevicesData", package: "LFData"),
        .product(name: "ExternalFundingData", package: "LFData"),
        .product(name: "AuthorizationManager", package: "LFNetwork"),
        .product(name: "BaseCard", package: "LFCard"),
        .product(name: "LFNetSpendCard", package: "LFCard"),
        .product(name: "LFSolidCard", package: "LFCard"),
        .product(name: "NetspendOnboarding", package: "LFOnboarding"),
        .product(name: "DevicesDomain", package: "LFDomain")
      ]
    ),
    .target(
      name: "LFDashboard",
      dependencies: [
        "LFUtilities", "LFStyleGuide", "LFLocalizable", "LFAccessibility", "BaseDashboard", "LFTransaction", "LFCryptoChart", "CodeScanner", "LFWalletAddress",
        .product(name: "OnboardingData", package: "LFData"),
        .product(name: "LFNetspendBank", package: "LFBank"),
        .product(name: "NetSpendData", package: "LFData"),
        .product(name: "ZerohashData", package: "LFData"),
        .product(name: "DevicesData", package: "LFData"),
        .product(name: "AuthorizationManager", package: "LFNetwork"),
        .product(name: "Services", package: "LFServices"),
        .product(name: "LFNetSpendCard", package: "LFCard"),
        .product(name: "LFAuthentication", package: "LFAuthentication")
      ]
    ),
    .target(
      name: "LFRewardDashboard",
      dependencies: [
        "LFUtilities", "LFStyleGuide", "LFLocalizable", "LFAccessibility", "LFTransaction", "CodeScanner", "LFRewards", "BaseDashboard",
        .product(name: "LFSolidBank", package: "LFBank"),
        .product(name: "OnboardingData", package: "LFData"),
        .product(name: "NetSpendData", package: "LFData"),
        .product(name: "ZerohashData", package: "LFData"),
        .product(name: "DevicesData", package: "LFData"),
        .product(name: "AuthorizationManager", package: "LFNetwork"),
        .product(name: "LFSolidCard", package: "LFCard"),
        .product(name: "Services", package: "LFServices"),
        .product(name: "SolidOnboarding", package: "LFOnboarding"),
        .product(name: "BiometricsManager", package: "LFAuthentication")
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
