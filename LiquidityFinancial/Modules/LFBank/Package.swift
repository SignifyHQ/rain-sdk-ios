// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LFBank",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "LFBank",
            targets: ["LFBank"])
    ],
    dependencies: [
      .package(name: "LFUtilities", path: "../LFUtilities"),
      .package(name: "LFStyleGuide", path: "../LFStyleGuide"),
      .package(name: "LFLocalizable", path: "../LFLocalizable"),
      .package(name: "LFServices", path: "../LFServices"),
      .package(name: "LFDomain", path: "../LFDomain"),
      .package(name: "LFData", path: "../LFData"),
      .package(name: "LFNetwork", path: "../LFNetwork"),
      .package(name: "LFAccountOnboarding", path: "../LFAccountOnboarding")
    ],
    targets: [
        .target(
            name: "LFBank",
            dependencies: [
              "LFUtilities", "LFStyleGuide", "LFLocalizable", "LFServices", "LFAccountOnboarding",
              .product(name: "OnboardingData", package: "LFData"),
              .product(name: "NetSpendData", package: "LFData"),
              .product(name: "AccountData", package: "LFData"),
              .product(name: "NetSpendDomain", package: "LFDomain"),
              .product(name: "OnboardingDomain", package: "LFDomain"),
              .product(name: "AccountDomain", package: "LFDomain"),
              .product(name: "AuthorizationManager", package: "LFNetwork")
            ]),
        .testTarget(
            name: "LFBankTests",
            dependencies: ["LFBank"])
    ]
)
