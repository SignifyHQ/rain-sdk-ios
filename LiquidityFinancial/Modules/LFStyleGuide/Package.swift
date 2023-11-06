// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LFStyleGuide",
    platforms: [.iOS(.v15), .macOS(.v10_14)],
    products: [
        .library(
            name: "LFStyleGuide",
            targets: ["LFStyleGuide"])
    ],
    dependencies: [
      .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", from: "6.6.2"),
      .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.2.0"),
      .package(name: "LFUtilities", path: "../LFUtilities"),
      .package(name: "LFAccessibility", path: "../LFAccessibility"),
      .package(name: "Services", path: "../LFServices"),
      .package(url: "https://github.com/marinofelipe/CurrencyText.git", from: "3.0.0")
    ],
    targets: [
        .target(
            name: "LFStyleGuide",
            dependencies: [
              "LFUtilities",
              "LFAccessibility",
              "Services",
              .product(name: "Lottie", package: "lottie-ios"),
              .product(name: "CurrencyTextSwiftUI", package: "CurrencyText")
            ],
            resources: [
              .process("XResources")
            ],
            plugins: [
              .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin")
            ]
        ),
        .testTarget(
            name: "LFStyleGuideTests",
            dependencies: ["LFStyleGuide"])
    ]
)
