// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "TestHelpers",
  platforms: [.iOS(.v16), .macOS(.v10_15)],
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
