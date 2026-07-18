// swift-tools-version: 6.1
import PackageDescription

let package = Package(
  name: "RainPortal",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "RainPortal",
      targets: ["RainPortal"]
    ),
  ],
  dependencies: [
    // RainCore comes via local path in-repo; published clients resolve it from its git tag.
    .package(path: "../rain-core-ios"),
    .package(url: "https://github.com/portal-hq/PortalSwift.git", exact: "7.1.0"),
  ],
  targets: [
    .target(
      name: "RainPortal",
      dependencies: [
        .product(name: "RainCore", package: "rain-core-ios"),
        .product(name: "PortalSwift", package: "PortalSwift"),
      ]
    ),
    .testTarget(
      name: "RainPortalTests",
      dependencies: ["RainPortal"]
    ),
  ]
)
