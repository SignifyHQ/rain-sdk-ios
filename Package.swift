// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// MARK: - Rain SDK (modular)
//
// One package, one product per wallet provider — a client links only the providers it uses:
//   • rain-core-ios    — vendor-free port + registry + Rain domain logic (no wallet vendor SDKs)
//   • rain-turnkey-ios — the Turnkey adapter (RainCore + tkhq/swift-sdk)
//   • rain-portal-ios  — the Portal MPC adapter (RainCore + PortalSwift)
//   • rain-privy-ios   — the Privy embedded-key adapter (RainCore + the Privy iOS SDK)
//
// Products are named for the SDK (`rain-portal-ios`), matching the Android artifact ids; the
// importable module keeps its Swift name (`import RainPortal`). Each adapter re-exports
// `RainCore`, so one import per provider is enough.
//
// The 1.x `RainSDK` migration umbrella has been removed — link the provider product you use.

let package = Package(
  name: "RainSDK",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "rain-core-ios",
      targets: ["RainCore"]
    ),
    .library(
      name: "rain-turnkey-ios",
      targets: ["RainTurnkey"]
    ),
    .library(
      name: "rain-portal-ios",
      targets: ["RainPortal"]
    ),
    .library(
      name: "rain-privy-ios",
      targets: ["RainPrivy"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/tkhq/swift-sdk.git", exact: "4.0.0"),
    .package(url: "https://github.com/Boilertalk/Web3.swift.git", exact: "0.8.8"),
    .package(url: "https://github.com/web3swift-team/web3swift.git", from: "3.3.2"),
    .package(url: "https://github.com/dagronf/QRCode", exact: "28.0.2"),
    .package(url: "https://github.com/portal-hq/PortalSwift.git", exact: "7.3.0"),
    .package(url: "https://github.com/privy-io/privy-ios", from: "2.14.0"),
  ],
  targets: [
    // Vendor-free core: no wallet vendor SDKs on this target.
    .target(
      name: "RainCore",
      dependencies: [
        .product(name: "QRCode", package: "QRCode"),
        .product(name: "Web3", package: "Web3.swift"),
        .product(name: "Web3PromiseKit", package: "Web3.swift"),
        .product(name: "Web3ContractABI", package: "Web3.swift"),
        .product(name: "web3swift", package: "web3swift"),
      ],
      path: "rain-core-ios/Sources/RainCore",
      resources: [
        .process("Resources")
      ]
    ),
    .testTarget(
      name: "RainCoreTests",
      dependencies: ["RainCore"],
      path: "rain-core-ios/Tests/RainCoreTests"
    ),

    .target(
      name: "RainTurnkey",
      dependencies: [
        "RainCore",
        .product(name: "TurnkeySwift", package: "swift-sdk"),
        .product(name: "TurnkeyHttp", package: "swift-sdk"),
        .product(name: "TurnkeyTypes", package: "swift-sdk"),
      ],
      path: "rain-turnkey-ios/Sources/RainTurnkey"
    ),
    .testTarget(
      name: "RainTurnkeyTests",
      dependencies: ["RainTurnkey"],
      path: "rain-turnkey-ios/Tests/RainTurnkeyTests"
    ),

    .target(
      name: "RainPortal",
      dependencies: [
        "RainCore",
        .product(name: "PortalSwift", package: "PortalSwift"),
      ],
      path: "rain-portal-ios/Sources/RainPortal"
    ),
    .testTarget(
      name: "RainPortalTests",
      dependencies: ["RainPortal"],
      path: "rain-portal-ios/Tests/RainPortalTests"
    ),

    // The Privy vendor SDK is owned here so core never imports Privy — linking this module is
    // what pulls it onto a client's graph.
    .target(
      name: "RainPrivy",
      dependencies: [
        "RainCore",
        .product(name: "Privy", package: "privy-ios"),
      ],
      path: "rain-privy-ios/Sources/RainPrivy"
    ),
    .testTarget(
      name: "RainPrivyTests",
      dependencies: ["RainPrivy"],
      path: "rain-privy-ios/Tests/RainPrivyTests"
    ),

  ]
)
