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
      targets: ["NetworkUtilities"]),
    .library(
      name: "NetworkTestHelpers",
      targets: ["NetworkTestHelpers"])
  ],
  dependencies: [
    .package(name: "LFUtilities", path: "../LFUtilities"),
    .package(name: "LFDomain", path: "../LFDomain"),
    .package(url: "https://github.com/hmlongco/Factory", from: "2.3.1"),
    .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.8.1")),
    .package(url: "https://github.com/krzysztofzablocki/Sourcery.git", from: "2.0.0")
  ],
  targets: [
    .target(
      name: "CoreNetwork",
      dependencies: ["LFUtilities", "AuthorizationManager", "NetworkUtilities", "Alamofire"]),
    .target(
      name: "AuthorizationManager",
      dependencies: [
        "LFUtilities", "Factory", "NetworkUtilities", "Alamofire",
        .product(name: "OnboardingDomain", package: "LFDomain")
      ]
    ),
    .target(
      name: "NetworkUtilities",
      dependencies: ["LFUtilities"]
    ),
    .target(name: "NetworkTestHelpers", dependencies: [
      "AuthorizationManager"
    ])
  ]
)
