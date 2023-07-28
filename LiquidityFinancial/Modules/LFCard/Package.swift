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
    .package(name: "LFUtilities", path: "../LFUtilities"),
    .package(name: "LFStyleGuide", path: "../LFStyleGuide"),
    .package(name: "LFLocalizable", path: "../LFLocalizable"),
    .package(name: "LFServices", path: "../LFServices")
  ],
  targets: [
    .target(
      name: "LFCard",
      dependencies: [
        "LFUtilities", "LFStyleGuide", "LFLocalizable", "LFServices"
      ]),
    .testTarget(
      name: "LFCardTests",
      dependencies: ["LFCard"])
  ]
)
