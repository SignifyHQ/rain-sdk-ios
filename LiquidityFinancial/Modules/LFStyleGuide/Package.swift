// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LFStyleGuide",
    platforms: [.iOS(.v16)],
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
      .package(name: "LFServices", path: "../LFServices"),
      .package(url: "https://github.com/marinofelipe/CurrencyText.git", from: "3.0.0"),
      .package(url: "https://github.com/dinhquan/SwiftTooltip", from: "0.1.0"),
      .package(url: "https://github.com/dagronf/qrcode.git", from: "20.0.0")
    ],
    targets: [
        .target(
            name: "LFStyleGuide",
            dependencies: [
              "LFUtilities",
              "LFAccessibility",
              .product(name: "Services", package: "LFServices"),
              .product(name: "AccountService", package: "LFServices"),
              .product(name: "Lottie", package: "lottie-ios"),
              .product(name: "CurrencyTextSwiftUI", package: "CurrencyText"),
              .product(name: "SwiftTooltip", package: "SwiftTooltip"),
              .product(name: "QRCode", package: "QRCode")
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
