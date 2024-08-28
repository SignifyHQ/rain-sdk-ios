// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "LFDashboard",
  platforms: [.iOS(.v15)],
  products: [
    .library(
      name: "LFRainDashboard",
      targets: ["LFRainDashboard"]),
    .library(
      name: "LFRewardDashboard",
      targets: ["LFRewardDashboard"]),
    .library(
      name: "GeneralFeature",
      targets: ["GeneralFeature"]),
    .library(
      name: "RainFeature",
      targets: ["RainFeature"])
  ],
  dependencies: [
    .package(name: "LFUtilities", path: "../LFUtilities"),
    .package(name: "LFStyleGuide", path: "../LFStyleGuide"),
    .package(name: "LFLocalizable", path: "../LFLocalizable"),
    .package(name: "LFAccessibility", path: "../LFAccessibility"),
    .package(name: "LFServices", path: "../LFServices"),
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
      name: "GeneralFeature",
      dependencies: [
        "LFUtilities", "LFStyleGuide", "LFLocalizable",
        .product(name: "ZerohashData", package: "LFData"),
        .product(name: "ZerohashDomain", package: "LFDomain"),
        .product(name: "RewardData", package: "LFData"),
        .product(name: "RewardDomain", package: "LFDomain"),
        .product(name: "CryptoChartData", package: "LFData"),
        .product(name: "OnboardingData", package: "LFData"),
        .product(name: "ExternalFundingData", package: "LFData"),
        .product(name: "AccountData", package: "LFData"),
        .product(name: "OnboardingDomain", package: "LFDomain"),
        .product(name: "AccountDomain", package: "LFDomain"),
        .product(name: "Services", package: "LFServices"),
        .product(name: "AuthorizationManager", package: "LFNetwork"),
        .product(name: "BiometricsManager", package: "LFAuthentication")
      ],
      path: "Sources/DashboardFeatures/GeneralFeature"
    ),
    .target(
      name: "RainFeature",
      dependencies: [
        "LFUtilities", "LFStyleGuide", "LFLocalizable", "GeneralFeature",
        .product(name: "ZerohashData", package: "LFData"),
        .product(name: "OnboardingData", package: "LFData"),
        .product(name: "ExternalFundingData", package: "LFData"),
        .product(name: "NetSpendData", package: "LFData"),
        .product(name: "AccountData", package: "LFData"),
        .product(name: "ZerohashDomain", package: "LFDomain"),
        .product(name: "NetspendDomain", package: "LFDomain"),
        .product(name: "OnboardingDomain", package: "LFDomain"),
        .product(name: "AccountDomain", package: "LFDomain"),
        .product(name: "Services", package: "LFServices"),
        .product(name: "AuthorizationManager", package: "LFNetwork"),
        .product(name: "RainOnboarding", package: "LFOnboarding"),
        .product(name: "BiometricsManager", package: "LFAuthentication")
      ],
      path: "Sources/DashboardFeatures/RainFeature"
    ),
    .target(
      name: "LFRainDashboard",
      dependencies: [
        "LFUtilities", "LFStyleGuide", "LFLocalizable", "LFAccessibility", "RainFeature", "CodeScanner",
        .product(name: "OnboardingData", package: "LFData"),
        .product(name: "NetSpendData", package: "LFData"),
        .product(name: "ZerohashData", package: "LFData"),
        .product(name: "DevicesData", package: "LFData"),
        .product(name: "ExternalFundingData", package: "LFData"),
        .product(name: "AuthorizationManager", package: "LFNetwork"),
        .product(name: "Services", package: "LFServices"),
        .product(name: "BiometricsManager", package: "LFAuthentication"),
        .product(name: "LFAuthentication", package: "LFAuthentication"),
        .product(name: "RainOnboarding", package: "LFOnboarding")
      ]
    ),
    .target(
      name: "LFRewardDashboard",
      dependencies: [
        "LFUtilities", "LFStyleGuide", "LFLocalizable", "LFAccessibility", "CodeScanner", "LFRewards",
        .product(name: "OnboardingData", package: "LFData"),
        .product(name: "DevicesData", package: "LFData"),
        .product(name: "AuthorizationManager", package: "LFNetwork"),
        .product(name: "Services", package: "LFServices"),
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
    .testTarget(
      name: "LFDashboardTests",
      dependencies: ["LFRainDashboard"])
  ]
)
