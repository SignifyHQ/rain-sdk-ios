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
          targets: ["CardDomain"])
    ],
    dependencies: [

    ],
    targets: [
        .target(
            name: "OnboardingDomain",
            dependencies: []),
        .target(
          name: "CardDomain",
          dependencies: []),
        .testTarget(
            name: "OnboardingDomainTests",
            dependencies: ["OnboardingDomain"])
    ]
)
