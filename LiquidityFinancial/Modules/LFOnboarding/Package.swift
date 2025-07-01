// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "LFOnboarding",
  platforms: [.iOS(.v16)],
  products: [
    .library(
      name: "BaseOnboarding", targets: ["BaseOnboarding"]
    ),
    .library(
      name: "RainOnboarding", targets: ["RainOnboarding"]
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
    .package(name: "LFNetwork", path: "../LFNetwork"),
    .package(name: "LFFeatureFlags", path: "../LFFeatureFlags"),
    .package(name: "LFAuthentication", path: "../LFAuthentication")
  ],
  targets: [
    .target(
      name: "BaseOnboarding",
      dependencies: [
        "LFUtilities", "LFStyleGuide", "LFLocalizable", "Factory", "iPhoneNumberField", "LFFeatureFlags",
        .product(name: "NetSpendData", package: "LFData"),
        .product(name: "OnboardingDomain", package: "LFDomain"),
        .product(name: "AccountDomain", package: "LFDomain"),
        .product(name: "PortalDomain", package: "LFDomain"),
        .product(name: "OnboardingData", package: "LFData"),
        .product(name: "AccountData", package: "LFData"),
        .product(name: "PortalData", package: "LFData"),
        .product(name: "LFAuthentication", package: "LFAuthentication")
      ],
      resources: [
        .process("ZResources")
      ]
    ),
    .target(
      name: "RainOnboarding",
      dependencies: [
        "BaseOnboarding", "SwiftSoup", "LFFeatureFlags",
        .product(name: "RainData", package: "LFData"),
        .product(name: "RainDomain", package: "LFDomain"),
        .product(name: "OnboardingData", package: "LFData"),
        .product(name: "AccountData", package: "LFData"),
        .product(name: "PortalDomain", package: "LFDomain"),
        .product(name: "PortalData", package: "LFData"),
        .product(name: "PlacesDomain", package: "LFDomain"),
        .product(name: "PlacesData", package: "LFData"),
        .product(name: "DevicesData", package: "LFData"),
        .product(name: "DevicesDomain", package: "LFDomain"),
        .product(name: "SmartyStreets", package: "smartystreets-ios-sdk"),
        .product(name: "AuthorizationManager", package: "LFNetwork"),
        .product(name: "BiometricsManager", package: "LFAuthentication"),
        .product(name: "LFAuthentication", package: "LFAuthentication")
      ]
    )
  ]
)
