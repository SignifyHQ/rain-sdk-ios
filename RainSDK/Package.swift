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
    .package(url: "https://github.com/portal-hq/PortalSwift.git", exact: "6.6.0")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "RainSDK",
      dependencies: [
        .product(name: "PortalSwift", package: "PortalSwift")
      ]
    ),
    .testTarget(
      name: "RainSDKTests",
      dependencies: ["RainSDK"]
    ),
  ]
)
