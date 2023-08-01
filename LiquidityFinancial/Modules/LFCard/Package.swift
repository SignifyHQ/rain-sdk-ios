// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "LFCard",
  platforms: [.iOS(.v15)],
  products: [
    .library(
      name: "LFCard",
      targets: ["LFCard"])
  ],
  dependencies: [
    .package(url: "https://github.com/hmlongco/Factory", from: "2.2.0"),
    .package(name: "CardDomain", path: "../LFDomain"),
    .package(name: "LFUtilities", path: "../LFUtilities"),
    .package(name: "LFStyleGuide", path: "../LFStyleGuide"),
    .package(name: "LFLocalizable", path: "../LFLocalizable"),
    .package(name: "LFServices", path: "../LFServices"),
    .package(name: "LFData", path: "../LFData")
  ],
  targets: [
    .target(
      name: "LFCard",
      dependencies: [
        "LFUtilities", "LFStyleGuide", "LFLocalizable", "LFServices", "CardDomain", "Factory",
        .product(name: "CardData", package: "LFData"),
        .product(name: "OnboardingData", package: "LFData"),
        .product(name: "NetSpendData", package: "LFData"),
        .product(name: "AccountData", package: "LFData")
      ]),
    .testTarget(
      name: "LFCardTests",
      dependencies: ["LFCard"])
  ]
)
