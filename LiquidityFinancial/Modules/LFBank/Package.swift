// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LFBank",
    platforms: [.iOS(.v15), .macOS(.v10_14)],
    products: [
        .library(
            name: "LFNetspendBank",
            targets: ["LFNetspendBank"]),
        .library(
            name: "LFBaseBank",
            targets: ["LFBaseBank"]),
        .library(
            name: "LFSolidBank",
            targets: ["LFSolidBank"])
    ],
    dependencies: [
      .package(name: "LFUtilities", path: "../LFUtilities"),
      .package(name: "LFStyleGuide", path: "../LFStyleGuide"),
      .package(name: "LFLocalizable", path: "../LFLocalizable"),
      .package(name: "LFServices", path: "../LFServices"),
      .package(name: "LFDomain", path: "../LFDomain"),
      .package(name: "LFData", path: "../LFData"),
      .package(name: "LFNetwork", path: "../LFNetwork"),
      .package(name: "LFTransaction", path: "../LFTransaction"),
      .package(name: "NetspendOnboarding", path: "../LFOnboarding")
    ],
    targets: [
        .target(
            name: "LFNetspendBank",
            dependencies: [
              "LFUtilities", "LFStyleGuide", "LFLocalizable", "LFTransaction", "NetspendOnboarding", "LFBaseBank",
              .product(name: "OnboardingData", package: "LFData"),
              .product(name: "NetSpendData", package: "LFData"),
              .product(name: "AccountData", package: "LFData"),
              .product(name: "NetspendDomain", package: "LFDomain"),
              .product(name: "OnboardingDomain", package: "LFDomain"),
              .product(name: "AccountDomain", package: "LFDomain"),
              .product(name: "Services", package: "LFServices"),
              .product(name: "AuthorizationManager", package: "LFNetwork")
            ]),
        .target(
            name: "LFBaseBank",
            dependencies: [
              "LFUtilities", "LFStyleGuide", "LFLocalizable", "LFTransaction", "NetspendOnboarding",
              .product(name: "OnboardingData", package: "LFData"),
              .product(name: "NetSpendData", package: "LFData"),
              .product(name: "AccountData", package: "LFData"),
              .product(name: "NetspendDomain", package: "LFDomain"),
              .product(name: "OnboardingDomain", package: "LFDomain"),
              .product(name: "AccountDomain", package: "LFDomain"),
              .product(name: "Services", package: "LFServices"),
              .product(name: "AuthorizationManager", package: "LFNetwork")
            ]),
        .target(
            name: "LFSolidBank",
            dependencies: [
              "LFUtilities", "LFStyleGuide", "LFLocalizable", "LFTransaction", "NetspendOnboarding", "LFBaseBank",
              .product(name: "OnboardingData", package: "LFData"),
              .product(name: "NetSpendData", package: "LFData"),
              .product(name: "SolidData", package: "LFData"),
              .product(name: "AccountData", package: "LFData"),
              .product(name: "NetspendDomain", package: "LFDomain"),
              .product(name: "OnboardingDomain", package: "LFDomain"),
              .product(name: "AccountDomain", package: "LFDomain"),
              .product(name: "Services", package: "LFServices"),
              .product(name: "AuthorizationManager", package: "LFNetwork")
            ]),
        .testTarget(
            name: "LFBankTests",
            dependencies: ["LFNetspendBank"])
    ]
)
