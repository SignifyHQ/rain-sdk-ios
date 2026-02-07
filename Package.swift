// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "RainSDK",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "RainSDK",
      targets: ["RainSDK"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/portal-hq/PortalSwift.git", exact: "6.6.0"),
    .package(url: "https://github.com/Boilertalk/Web3.swift.git", exact: "0.8.8"),
    .package(url: "https://github.com/web3swift-team/web3swift.git", from: "3.3.2")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "RainSDK",
      dependencies: [
        .product(name: "PortalSwift", package: "PortalSwift"),
        .product(name: "Web3", package: "Web3.swift"),
        .product(name: "Web3PromiseKit", package: "Web3.swift"),
        .product(name: "Web3ContractABI", package: "Web3.swift"),
        .product(name: "web3swift", package: "web3swift")
      ],
      resources: [
        .process("Resources")
      ]
    ),
    .testTarget(
      name: "RainSDKTests",
      dependencies: ["RainSDK"]
    ),
  ]
)
