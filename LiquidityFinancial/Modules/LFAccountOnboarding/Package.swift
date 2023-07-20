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
          name: "AvalancheAccountOnboarding",
          targets: ["AvalancheAccountOnboarding"]
        ),
        .library(
          name: "CardanoAccountOnboarding",
          targets: ["CardanoAccountOnboarding"]
        )
    ],
    dependencies: [
      .package(url: "https://github.com/MojtabaHs/iPhoneNumberField.git", from: "0.10.1"),
      .package(url: "https://github.com/smartystreets/smartystreets-ios-sdk", branch: "master"),
      .package(url: "https://github.com/hmlongco/Factory", from: "2.2.0"),
      .package(name: "LFUtilities", path: "../LFUtilities"),
      .package(name: "LFStyleGuide", path: "../LFStyleGuide"),
      .package(name: "OnboardingDomain", path: "../LFDomain"),
      .package(name: "LFData", path: "../LFData"),
      .package(name: "LFLocalizable", path: "../LFLocalizable")
    ],
    targets: [
        .target(
          name: "LFAccountOnboarding",
          dependencies: [
            "LFUtilities", "OnboardingDomain", "LFStyleGuide", "LFLocalizable", "Factory", "iPhoneNumberField",
            .product(name: "OnboardingData", package: "LFData"),
            .product(name: "NetSpendData", package: "LFData"),
            .product(name: "SmartyStreets", package: "smartystreets-ios-sdk")
          ],
          resources: [
            .process("ZResources")
          ]
        ),
        .target(name: "AvalancheAccountOnboarding", dependencies: ["LFAccountOnboarding"]),
        .target(name: "CardanoAccountOnboarding", dependencies: ["LFAccountOnboarding"]),
        .testTarget(
            name: "LFAccountOnboardingTests",
            dependencies: ["LFAccountOnboarding"])
    ]
)
