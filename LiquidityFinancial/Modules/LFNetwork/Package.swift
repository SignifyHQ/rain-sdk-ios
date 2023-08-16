// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LFNetwork",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "CoreNetwork",
            targets: ["CoreNetwork"]),
        .library(
          name: "AuthorizationManager",
          targets: ["AuthorizationManager"]),
        .library(
          name: "NetworkUtilities",
          targets: ["NetworkUtilities"])
    ],
    dependencies: [
      .package(name: "LFUtilities", path: "../LFUtilities"),
      .package(name: "LFDomain", path: "../LFDomain"),
      .package(url: "https://github.com/hmlongco/Factory", from: "2.2.0")
    ],
    targets: [
        .target(
            name: "CoreNetwork",
            dependencies: ["LFUtilities", "AuthorizationManager", "NetworkUtilities"]),
        .target(
          name: "AuthorizationManager",
          dependencies: [
            "LFUtilities", "Factory", "NetworkUtilities",
            .product(name: "OnboardingDomain", package: "LFDomain")
          ]
        ),
        .target(
          name: "NetworkUtilities",
          dependencies: ["LFUtilities"]),
    ]
)
