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
      .package(name: "LFUtilities", path: "../LFUtilities"),
      .package(name: "LFStyleGuide", path: "../LFStyleGuide"),
      .package(name: "OnboardingDomain", path: "../LFDomain")
    ],
    targets: [
        .target(name: "LFAccountOnboarding", dependencies: ["LFUtilities", "OnboardingDomain", "LFStyleGuide"]),
        .target(name: "AvalancheAccountOnboarding", dependencies: ["LFAccountOnboarding"]),
        .target(name: "CardanoAccountOnboarding", dependencies: ["LFAccountOnboarding"]),
        .testTarget(
            name: "LFAccountOnboardingTests",
            dependencies: ["LFAccountOnboarding"])
    ]
)
