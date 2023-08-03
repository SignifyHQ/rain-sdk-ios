// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LFDomain",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "OnboardingDomain",
            targets: ["OnboardingDomain"]),
        .library(
          name: "CardDomain",
          targets: ["CardDomain"]),
        .library(
          name: "AccountDomain",
          targets: ["AccountDomain"]),
        .library(
          name: "ExternalFundingDomain",
          targets: ["ExternalFundingDomain"])
    ],
    dependencies: [
      .package(name: "LFServices", path: "../LFServices"),
      .package(url: "https://github.com/hmlongco/Factory", from: "2.2.0")
    ],
    targets: [
        .target(
            name: "OnboardingDomain",
            dependencies: []),
        .target(
          name: "CardDomain",
          dependencies: ["LFServices"]),
        .target(
          name: "AccountDomain",
          dependencies: [
            "LFServices", "Factory"
          ]
        ),
        .target(
          name: "ExternalFundingDomain",
          dependencies: [
            "LFServices"
          ]
        ),
        .testTarget(
            name: "OnboardingDomainTests",
            dependencies: ["OnboardingDomain"])
    ]
)
