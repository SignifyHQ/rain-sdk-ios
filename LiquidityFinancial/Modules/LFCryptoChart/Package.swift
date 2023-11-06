// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LFCryptoChart",
    platforms: [.iOS(.v15), .macOS(.v10_14)],
    products: [
        .library(
            name: "LFCryptoChart",
            targets: ["LFCryptoChart"]),
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
        name: "LFCryptoChart",
        dependencies: [
          "LFUtilities", "LFStyleGuide", "LFLocalizable",
          .product(name: "Services", package: "LFServices"),
          .product(name: "OnboardingData", package: "LFData"),
          .product(name: "NetSpendData", package: "LFData"),
          .product(name: "CryptoChartData", package: "LFData"),
          .product(name: "AuthorizationManager", package: "LFNetwork")
        ]),
      .testTarget(
        name: "LFCryptoChartTests",
        dependencies: ["LFCryptoChart"])
    ]
)
