// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "LFData",
  platforms: [.iOS(.v15)],
  products: [
    .library(
      name: "OnboardingData",
      targets: ["OnboardingData"]),
    .library(
      name: "DataUtilities",
      targets: ["DataUtilities"]),
    .library(
      name: "AuthorizationManager",
      targets: ["AuthorizationManager"]),
    .library(
      name: "NetSpendData",
      targets: ["NetSpendData"])
  ],
  dependencies: [
    .package(name: "OnboardingDomain", path: "../LFDomain"),
    .package(name: "LFNetwork", path: "../LFNetwork"),
    .package(name: "LFUtilities", path: "../LFUtilities"),
    .package(name: "LFServices", path: "../LFServices")
  ],
  targets: [
    .target(
      name: "OnboardingData",
      dependencies: ["DataUtilities", "LFNetwork", "OnboardingDomain", "AuthorizationManager"]),
    .target(
      name: "DataUtilities",
      dependencies: ["LFNetwork"]),
    .target(
      name: "AuthorizationManager",
      dependencies: ["DataUtilities", "OnboardingDomain", "LFUtilities"]),
    .target(
      name: "NetSpendData",
      dependencies: ["LFNetwork", "LFServices", "DataUtilities", "LFUtilities"]),
    .testTarget(
      name: "OnboardingDataTests",
      dependencies: ["OnboardingData"])
  ]
)
