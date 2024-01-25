// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "LFOnboarding",
  platforms: [.iOS(.v15)],
  products: [
    .library(
      name: "NetspendOnboarding", targets: ["NetspendOnboarding"]
    ),
    .library(
      name: "OnboardingComponents", targets: ["OnboardingComponents"]
    ),
    .library(
      name: "SolidOnboarding", targets: ["SolidOnboarding"]
    ),
    .library(
      name: "NoBankOnboarding", targets: ["NoBankOnboarding"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/MojtabaHs/iPhoneNumberField.git", from: "0.10.1"),
    .package(url: "https://github.com/smartystreets/smartystreets-ios-sdk", branch: "master"),
    .package(url: "https://github.com/hmlongco/Factory", from: "2.3.1"),
    .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.6.1"),
    .package(name: "LFUtilities", path: "../LFUtilities"),
    .package(name: "LFStyleGuide", path: "../LFStyleGuide"),
    .package(name: "LFDomain", path: "../LFDomain"),
    .package(name: "LFData", path: "../LFData"),
    .package(name: "LFLocalizable", path: "../LFLocalizable"),
    .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", from: "6.6.2"),
    .package(name: "LFRewards", path: "../LFRewards"),
    .package(name: "LFNetwork", path: "../LFNetwork"),
    .package(url: "https://github.com/nalexn/ViewInspector", from: "0.9.8"),
    .package(name: "TestHelpers", path: "../TestHelpers"),
    .package(name: "LFFeatureFlags", path: "../LFFeatureFlags"),
    .package(name: "LFAuthentication", path: "../LFAuthentication"),
    .package(name: "LFServices", path: "../LFServices")
  ],
  targets: [
    .target(
      name: "OnboardingComponents",
      dependencies: [
        "LFUtilities", "LFStyleGuide", "LFLocalizable", "Factory", "iPhoneNumberField", "LFFeatureFlags",
        .product(name: "NetSpendData", package: "LFData"),
        .product(name: "OnboardingDomain", package: "LFDomain"),
        .product(name: "AccountDomain", package: "LFDomain"),
        .product(name: "OnboardingData", package: "LFData"),
        .product(name: "AccountData", package: "LFData")
      ],
      resources: [
        .process("ZResources")
      ]
    ),
    .target(
      name: "NetspendOnboarding",
      dependencies: [
        "OnboardingComponents", "SwiftSoup", "LFFeatureFlags",
        .product(name: "OnboardingData", package: "LFData"),
        .product(name: "AccountData", package: "LFData"),
        .product(name: "DevicesData", package: "LFData"),
        .product(name: "ZerohashData", package: "LFData"),
        .product(name: "ZerohashDomain", package: "LFDomain"),
        .product(name: "DevicesDomain", package: "LFDomain"),
        .product(name: "SmartyStreets", package: "smartystreets-ios-sdk"),
        .product(name: "AuthorizationManager", package: "LFNetwork"),
        .product(name: "BiometricsManager", package: "LFAuthentication"),
        .product(name: "LFAuthentication", package: "LFAuthentication")
      ]
    ),
    .target(
      name: "NoBankOnboarding",
      dependencies: [
        "OnboardingComponents", "SwiftSoup", "LFFeatureFlags",
        .product(name: "OnboardingData", package: "LFData"),
        .product(name: "AccountData", package: "LFData"),
        .product(name: "DevicesData", package: "LFData"),
        .product(name: "ZerohashData", package: "LFData"),
        .product(name: "ZerohashDomain", package: "LFDomain"),
        .product(name: "DevicesDomain", package: "LFDomain"),
        .product(name: "SmartyStreets", package: "smartystreets-ios-sdk"),
        .product(name: "AuthorizationManager", package: "LFNetwork"),
        .product(name: "BiometricsManager", package: "LFAuthentication"),
        .product(name: "LFAuthentication", package: "LFAuthentication")
      ]
    ),
    .target(
      name: "SolidOnboarding",
      dependencies: [
        "LFUtilities", "LFStyleGuide", "LFLocalizable", "Factory", "LFRewards", "OnboardingComponents", "LFFeatureFlags",
        .product(name: "SolidData", package: "LFData"),
        .product(name: "RewardData", package: "LFData"),
        .product(name: "RewardDomain", package: "LFDomain"),
        .product(name: "SmartyStreets", package: "smartystreets-ios-sdk"),
        .product(name: "AuthorizationManager", package: "LFNetwork"),
        .product(name: "AccountData", package: "LFData"),
        .product(name: "DevicesData", package: "LFData"),
        .product(name: "SolidDomain", package: "LFDomain"),
        .product(name: "DevicesDomain", package: "LFDomain"),
        .product(name: "BiometricsManager", package: "LFAuthentication"),
        .product(name: "LFAuthentication", package: "LFAuthentication"),
        .product(name: "AccountService", package: "LFServices")
      ]
    ),
    .testTarget(
      name: "PhoneNumberViewModelTests",
      dependencies: [
        .product(name: "DomainTestHelpers", package: "LFDomain"),
        "NetspendOnboarding",
        "TestHelpers",
        "ViewInspector"
      ]
    )
  ]
)
