// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LFAccountOnboarding",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "LFAccountOnboarding",
            targets: ["LFAccountOnboarding"]
        ),
        .library(
          name: "DogeOnboarding",
          targets: ["DogeOnboarding"]
        )
    ],
    dependencies: [
      .package(url: "https://github.com/MojtabaHs/iPhoneNumberField.git", from: "0.10.1"),
      .package(url: "https://github.com/smartystreets/smartystreets-ios-sdk", branch: "master"),
      .package(url: "https://github.com/hmlongco/Factory", from: "2.2.0"),
      .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.6.1"),
      .package(name: "LFUtilities", path: "../LFUtilities"),
      .package(name: "LFStyleGuide", path: "../LFStyleGuide"),
      .package(name: "OnboardingDomain", path: "../LFDomain"),
      .package(name: "LFData", path: "../LFData"),
      .package(name: "LFLocalizable", path: "../LFLocalizable"),
      .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", from: "6.6.2"),
      .package(name: "LFRewards", path: "../LFRewards"),
      .package(name: "LFNetwork", path: "../LFNetwork"),
    ],
    targets: [
        .target(
          name: "LFAccountOnboarding",
          dependencies: [
            "LFUtilities", "OnboardingDomain", "LFStyleGuide", "LFLocalizable", "Factory", "iPhoneNumberField",
            "DogeOnboarding", "SwiftSoup", "LFRewards",
            .product(name: "OnboardingData", package: "LFData"),
            .product(name: "AccountData", package: "LFData"),
            .product(name: "NetSpendData", package: "LFData"),
            .product(name: "RewardData", package: "LFData"),
            .product(name: "DevicesData", package: "LFData"),
            .product(name: "SmartyStreets", package: "smartystreets-ios-sdk"),
            .product(name: "AuthorizationManager", package: "LFNetwork")
          ],
          resources: [
            .process("ZResources")
          ]
        ),
        .target(
          name: "DogeOnboarding",
          dependencies: [
            "LFUtilities", "LFStyleGuide", "LFLocalizable", "Factory",
            .product(name: "NetSpendData", package: "LFData")
          ],
          resources: [
            .process("ZResources")
          ]
        ),
        .testTarget(
            name: "LFAccountOnboardingTests",
            dependencies: ["LFAccountOnboarding"])
    ]
)
