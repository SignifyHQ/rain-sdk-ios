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
      name: "NetworkMocks",
      targets: ["NetworkMocks"])
  ],
  dependencies: [
    .package(name: "LFUtilities", path: "../LFUtilities"),
    .package(name: "LFDomain", path: "../LFDomain"),
    .package(url: "https://github.com/hmlongco/Factory", from: "2.3.0"),
    .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.7.1")),
    .package(url: "https://github.com/birdrides/mockingbird", .upToNextMajor(from: "0.20.0"))
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
      dependencies: ["LFUtilities"]),
    .target(
      name: "NetworkMocks",
      dependencies: [
        "AuthorizationManager",
        .product(name: "Mockingbird", package: "mockingbird")
      ]
    )
  ]
)
