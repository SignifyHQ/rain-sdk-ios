// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "LFWalletAddress",
  platforms: [.iOS(.v15)],
  products: [
    .library(
      name: "LFWalletAddress",
      targets: ["LFWalletAddress"])
  ],
  dependencies: [
    .package(name: "LFUtilities", path: "../LFUtilities"),
    .package(name: "LFStyleGuide", path: "../LFStyleGuide"),
    .package(name: "LFLocalizable", path: "../LFLocalizable"),
    .package(name: "LFServices", path: "../LFServices"),
    .package(name: "LFData", path: "../LFData"),
    .package(name: "LFNetwork", path: "../LFNetwork")
  ],
  targets: [
    .target(
      name: "LFWalletAddress",
      dependencies: [
        "LFUtilities", "LFStyleGuide", "LFLocalizable", "LFServices",
        .product(name: "OnboardingData", package: "LFData"),
        .product(name: "NetSpendData", package: "LFData"),
        .product(name: "ZerohashData", package: "LFData"),
        .product(name: "AuthorizationManager", package: "LFNetwork")
      ]
    ),
    .testTarget(
      name: "LFWalletAddressTests",
      dependencies: ["LFWalletAddress"])
  ]
)
