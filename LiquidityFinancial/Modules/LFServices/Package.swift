// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LFServices",
    platforms: [.iOS(.v15), .macOS(.v10_14)],
    products: [
        .library(name: "LFServices", targets: ["LFServices", "NetspendSdk", "LinkKit", "FraudForce"])
    ],
    dependencies: [
      .package(name: "LFUtilities", path: "../LFUtilities"),
      .package(url: "https://github.com/verygoodsecurity/vgs-show-ios.git", from: "1.1.6"),
      .package(url: "https://github.com/underdog-tech/pinwheel-ios-sdk.git", from: "2.3.15"),
      .package(url: "https://github.com/intercom/intercom-ios", from: "15.1.3"),
      .package(url: "https://github.com/marinofelipe/CurrencyText.git", from: "3.0.0"),
      .package(url: "https://github.com/hmlongco/Factory", from: "2.3.1"),
      .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.0.0"),
      .package(url: "https://github.com/segmentio/analytics-ios", from: "4.1.8"),
      .package(url: "https://github.com/Datadog/dd-sdk-ios.git", from: "2.2.1"),
      .package(url: "https://github.com/verygoodsecurity/vgs-collect-ios.git", from: "1.15.1")
    ],
    targets: [
        .target(
            name: "LFServices",
            dependencies: [
              "LFUtilities", "Factory",
              .product(name: "Segment", package: "analytics-ios"),
              .product(name: "VGSShowSDK", package: "vgs-show-ios"),
              .product(name: "PinwheelSDK", package: "pinwheel-ios-sdk"),
              .product(name: "CurrencyText", package: "CurrencyText"),
              .product(name: "Intercom", package: "intercom-ios"),
              .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
              .product(name: "DatadogCore", package: "dd-sdk-ios"),
              .product(name: "DatadogTrace", package: "dd-sdk-ios"),
              .product(name: "DatadogRUM", package: "dd-sdk-ios"),
              .product(name: "DatadogLogs", package: "dd-sdk-ios"),
              .product(name: "VGSCollectSDK", package: "vgs-collect-ios"),
            ],
            resources: [
              .process("Resources")
            ]
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
            dependencies: ["LFServices"])
    ]
)
