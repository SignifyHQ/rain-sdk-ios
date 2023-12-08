// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LFAuthentication",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "LFAuthentication",
            targets: ["LFAuthentication"]),
    ],
    dependencies: [
      .package(name: "LFData", path: "../LFData"),
      .package(name: "LFDomain", path: "../LFDomain"),
      .package(name: "LFUtilities", path: "../LFUtilities"),
      .package(name: "LFStyleGuide", path: "../LFStyleGuide"),
      .package(name: "LFLocalizable", path: "../LFLocalizable"),
      .package(name: "TestHelpers", path: "../TestHelpers")
    ],
    targets: [
        .target(
            name: "LFAuthentication",
            dependencies: [
              .product(name: "AccountData", package: "LFData"),
              .product(name: "AccountDomain", package: "LFDomain"),
              "LFUtilities",
              "LFStyleGuide",
              "LFLocalizable"
            ]
        ),
        .testTarget(
            name: "CreatePasswordViewModelTests",
            dependencies: [
              "LFAuthentication",
              "TestHelpers"
            ]
        ),
    ]
)
