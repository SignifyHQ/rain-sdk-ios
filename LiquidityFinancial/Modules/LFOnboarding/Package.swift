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
      name: "UIComponents", targets: ["UIComponents"]
    ),
    .library(
      name: "BaseOnboarding", targets: ["BaseOnboarding"]
    ),
    .library(
      name: "SolidOnboarding", targets: ["SolidOnboarding"]
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
    .package(name: "TestHelpers", path: "../TestHelpers")
  ],
  targets: [
    .target(
      name: "BaseOnboarding",
      dependencies: [
        "LFUtilities", "LFStyleGuide", "LFLocalizable", "Factory", "iPhoneNumberField",
        .product(name: "OnboardingDomain", package: "LFDomain"),
        .product(name: "AccountDomain", package: "LFDomain"),
        .product(name: "OnboardingData", package: "LFData"),
        .product(name: "AccountData", package: "LFData")
      ]
    ),
    .target(
      name: "UIComponents",
      dependencies: [
        "LFUtilities", "LFStyleGuide", "LFLocalizable", "Factory",
        .product(name: "NetSpendData", package: "LFData")
      ],
      resources: [
        .process("ZResources")
      ]
    ),
    .target(
      name: "NetspendOnboarding",
      dependencies: [
        "UIComponents", "SwiftSoup", "LFRewards", "BaseOnboarding",
        .product(name: "OnboardingData", package: "LFData"),
        .product(name: "AccountData", package: "LFData"),
        .product(name: "RewardData", package: "LFData"),
        .product(name: "DevicesData", package: "LFData"),
        .product(name: "ZerohashData", package: "LFData"),
        .product(name: "ZerohashDomain", package: "LFDomain"),
        .product(name: "DevicesDomain", package: "LFDomain"),
        .product(name: "SmartyStreets", package: "smartystreets-ios-sdk"),
        .product(name: "AuthorizationManager", package: "LFNetwork")
      ]
    ),
    .target(
      name: "SolidOnboarding",
      dependencies: [
        "LFUtilities", "LFStyleGuide", "LFLocalizable", "Factory", "LFRewards",
        .product(name: "SolidData", package: "LFData"),
        .product(name: "RewardData", package: "LFData"),
        .product(name: "RewardDomain", package: "LFDomain"),
        .product(name: "SmartyStreets", package: "smartystreets-ios-sdk"),
        .product(name: "AuthorizationManager", package: "LFNetwork"),
        .product(name: "AccountData", package: "LFData"),
        .product(name: "DevicesData", package: "LFData"),
        .product(name: "SolidDomain", package: "LFDomain"),
        .product(name: "DevicesDomain", package: "LFDomain")
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
