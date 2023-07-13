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
      targets: ["DataUtilities"])
  ],
  dependencies: [
    .package(name: "OnboardingDomain", path: "../LFDomain"),
    .package(name: "LFNetwork", path: "../LFNetwork")
  ],
  targets: [
    .target(
      name: "OnboardingData",
      dependencies: ["DataUtilities", "LFNetwork", "OnboardingDomain"]),
    .target(
      name: "DataUtilities",
      dependencies: ["LFNetwork"]),
    .testTarget(
      name: "OnboardingDataTests",
      dependencies: ["OnboardingData"])
  ]
)
