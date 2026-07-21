// swift-tools-version: 6.1
import PackageDescription

let package = Package(
  name: "RainPrivy",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "RainPrivy",
      targets: ["RainPrivy"]
    ),
  ],
  dependencies: [
    // RainCore comes via local path in-repo; published clients resolve it from its git tag.
    .package(path: "../rain-core-ios"),
    // Privy vendor SDK (binary xcframework, product "Privy", target "PrivySDK"). Owned here so
    // core never imports Privy — linking this module is what pulls it onto a client's graph.
    .package(url: "https://github.com/privy-io/privy-ios", from: "2.14.0"),
  ],
  targets: [
    .target(
      name: "RainPrivy",
      dependencies: [
        .product(name: "RainCore", package: "rain-core-ios"),
        .product(name: "Privy", package: "privy-ios"),
      ]
    ),
    .testTarget(
      name: "RainPrivyTests",
      dependencies: ["RainPrivy"]
    ),
  ]
)
