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
      .package(name: "LFUtilities", path: "../LFUtilities"),
      .package(name: "LFStyleGuide", path: "../LFStyleGuide"),
      .package(name: "LFLocalizable", path: "../LFLocalizable")
    ],
    targets: [
        .target(
            name: "LFAuthentication",
            dependencies: [
              "LFUtilities", "LFStyleGuide", "LFLocalizable"
            ]
        ),
        .testTarget(
            name: "LFAuthenticationTests",
            dependencies: ["LFAuthentication"]
        ),
    ]
)
