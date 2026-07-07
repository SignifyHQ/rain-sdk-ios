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
    // The Privy vendor SDK will be added here (as a target dependency) when the adapter is built.
    .package(path: "../rain-core"),
  ],
  targets: [
    .target(
      name: "RainPrivy",
      dependencies: [
        .product(name: "RainCore", package: "rain-core"),
      ]
    ),
    .testTarget(
      name: "RainPrivyTests",
      dependencies: ["RainPrivy"]
    ),
  ]
)
