// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "TestHelpers",
  platforms: [.iOS(.v15), .macOS(.v10_14)],
  products: [
    .library(
      name: "TestHelpers",
      targets: ["TestHelpers"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/Quick/Nimble.git", from: "12.0.0")
  ],
  targets: [
    .target(
      name: "TestHelpers",
      dependencies: ["Nimble"]
    )
  ]
)
