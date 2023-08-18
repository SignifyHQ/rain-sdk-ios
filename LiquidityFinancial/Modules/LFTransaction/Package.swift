// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LFTransaction",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "LFTransaction",
            targets: ["LFTransaction"])
    ],
    dependencies: [
      .package(url: "https://github.com/hmlongco/Factory", from: "2.2.0"),
      .package(name: "LFDomain", path: "../LFDomain"),
      .package(name: "LFUtilities", path: "../LFUtilities"),
      .package(name: "LFStyleGuide", path: "../LFStyleGuide"),
      .package(name: "LFLocalizable", path: "../LFLocalizable"),
      .package(name: "LFServices", path: "../LFServices"),
      .package(name: "LFData", path: "../LFData")
    ],
    targets: [
        .target(
            name: "LFTransaction",
            dependencies: [
              "LFUtilities", "LFStyleGuide", "LFLocalizable", "LFServices", "Factory",
              .product(name: "OnboardingData", package: "LFData"),
              .product(name: "NetSpendData", package: "LFData"),
              .product(name: "AccountData", package: "LFData"),
              .product(name: "NetSpendDomain", package: "LFDomain")
            ]),
        .testTarget(
            name: "LFTransactionTests",
            dependencies: ["LFTransaction"])
    ]
)
