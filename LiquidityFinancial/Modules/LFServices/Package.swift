// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "LFServices",
  platforms: [.iOS(.v15)],
  products: [
    .library(
      name: "Services",
      targets: [
        "Services", "NetspendSdk", "LinkKit", "FraudForce"
      ]
    ),
    .library(
      name: "AccountService",
      targets: ["AccountService"]
    ),
    .library(
      name: "BankService",
      targets: ["BankService"]
    ),
    .library(
      name: "EnvironmentService",
      targets: ["EnvironmentService"]
    )
  ],
  dependencies: [
    .package(name: "LFUtilities", path: "../LFUtilities"),
    .package(url: "https://github.com/verygoodsecurity/vgs-show-ios.git", from: "1.1.7"),
    .package(url: "https://github.com/underdog-tech/pinwheel-ios-sdk.git", from: "2.3.15"),
    .package(url: "https://github.com/marinofelipe/CurrencyText.git", from: "3.0.0"),
    .package(url: "https://github.com/hmlongco/Factory", from: "2.3.1"),
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.0.0"),
    .package(url: "https://github.com/segmentio/analytics-ios", from: "4.1.8"),
    .package(url: "https://github.com/Datadog/dd-sdk-ios.git", from: "2.4.0"),
    .package(url: "https://github.com/verygoodsecurity/vgs-collect-ios.git", .exact("1.15.3")),
    .package(url: "https://github.com/portal-hq/PortalSwift", from: "3.0.5")
  ],
  targets: [
    .target(
      name: "Services",
      dependencies: [
        "LFUtilities", "Factory", "EnvironmentService",
        .product(name: "Segment", package: "analytics-ios"),
        .product(name: "VGSShowSDK", package: "vgs-show-ios"),
        .product(name: "PinwheelSDK", package: "pinwheel-ios-sdk"),
        .product(name: "CurrencyText", package: "CurrencyText"),
        .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
        .product(name: "DatadogCore", package: "dd-sdk-ios"),
        .product(name: "DatadogTrace", package: "dd-sdk-ios"),
        .product(name: "DatadogRUM", package: "dd-sdk-ios"),
        .product(name: "DatadogLogs", package: "dd-sdk-ios"),
        .product(name: "DatadogCrashReporting", package: "dd-sdk-ios"),
        .product(name: "VGSCollectSDK", package: "vgs-collect-ios"),
        .product(name: "PortalSwift", package: "PortalSwift")
      ],
      resources: [
        .process("Resources")
      ]
    ),
    .target(
      name: "AccountService",
      dependencies: ["LFUtilities", "Factory"]
    ),
    .target(
      name: "BankService",
      dependencies: ["Factory"]
    ),
    .target(
      name: "EnvironmentService",
      dependencies: ["LFUtilities", "Factory"]
    ),
    .binaryTarget(
      name: "NetspendSdk",
      path: "../../Frameworks/NetspendSdk.xcframework"
    ),
    .binaryTarget(
      name: "FraudForce",
      path: "../../Frameworks/FraudForce.xcframework"
    ),
    .binaryTarget(
      name: "LinkKit",
      path: "../../Frameworks/LinkKit.xcframework"
    ),
    .testTarget(
      name: "LFServicesTests",
      dependencies: ["Services"])
  ]
)
