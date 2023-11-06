// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LFTransaction",
    platforms: [.iOS(.v15), .macOS(.v10_14)],
    products: [
        .library(
            name: "LFTransaction",
            targets: ["LFTransaction"])
    ],
    dependencies: [
      .package(url: "https://github.com/hmlongco/Factory", from: "2.3.1"),
      .package(name: "LFDomain", path: "../LFDomain"),
      .package(name: "LFUtilities", path: "../LFUtilities"),
      .package(name: "LFStyleGuide", path: "../LFStyleGuide"),
      .package(name: "LFLocalizable", path: "../LFLocalizable"),
      .package(name: "LFServices", path: "../LFServices"),
      .package(name: "LFData", path: "../LFData"),
      .package(name: "LFWalletAddress", path: "../LFWalletAddress")
    ],
    targets: [
        .target(
            name: "LFTransaction",
            dependencies: [
              "LFUtilities", "LFStyleGuide", "LFLocalizable", "Factory", "LFWalletAddress",
              .product(name: "OnboardingData", package: "LFData"),
              .product(name: "NetSpendData", package: "LFData"),
              .product(name: "AccountData", package: "LFData"),
              .product(name: "NetspendDomain", package: "LFDomain"),
              .product(name: "ZerohashData", package: "LFData"),
              .product(name: "RewardData", package: "LFData"),
              .product(name: "Services", package: "LFServices"),
              .product(name: "RewardDomain", package: "LFDomain")
            ]),
        .testTarget(
            name: "LFTransactionTests",
            dependencies: ["LFTransaction"])
    ]
)
