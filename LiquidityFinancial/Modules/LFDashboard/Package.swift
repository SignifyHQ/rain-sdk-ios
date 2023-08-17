// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "LFDashboard",
  platforms: [.iOS(.v15)],
  products: [
    .library(
      name: "LFDashboard",
      targets: ["LFDashboard"])
  ],
  dependencies: [
    .package(name: "LFUtilities", path: "../LFUtilities"),
    .package(name: "LFStyleGuide", path: "../LFStyleGuide"),
    .package(name: "LFLocalizable", path: "../LFLocalizable"),
    .package(name: "LFServices", path: "../LFServices"),
    .package(name: "LFCard", path: "../LFCard"),
    .package(name: "LFBank", path: "../LFBank"),
    .package(name: "LFData", path: "../LFData"),
    .package(name: "LFNetwork", path: "../LFNetwork"),
    .package(url: "https://github.com/twostraws/CodeScanner", from: "2.0.0")
  ],
  targets: [
    .target(
      name: "LFDashboard",
      dependencies: [
        "LFUtilities", "LFStyleGuide", "LFLocalizable", "LFServices", "LFCard", "LFBank",
        .product(name: "OnboardingData", package: "LFData"),
        .product(name: "NetSpendData", package: "LFData"),
        .product(name: "AuthorizationManager", package: "LFNetwork")
      ]
    ),
    .testTarget(
      name: "LFDashboardTests",
      dependencies: ["LFDashboard"])
  ]
)
