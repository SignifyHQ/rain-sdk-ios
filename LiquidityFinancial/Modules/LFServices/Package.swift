// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LFServices",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "LFServices", targets: ["LFServices", "NetspendSdk", "LinkKit", "FraudForce"])
    ],
    dependencies: [
      .package(name: "LFUtilities", path: "../LFUtilities"),
      .package(url: "https://github.com/verygoodsecurity/vgs-show-ios.git", from: "1.1.6"),
      .package(url: "https://github.com/intercom/intercom-ios", from: "15.1.3")
    ],
    targets: [
        .target(
            name: "LFServices",
            dependencies: [
              "LFUtilities",
              .product(name: "VGSShowSDK", package: "vgs-show-ios"),
              .product(name: "Intercom", package: "intercom-ios")
            ]),
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
