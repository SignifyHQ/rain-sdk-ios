// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// MARK: - Rain SDK (modular)
//
// The SDK is split into separate packages so a client links only the providers it uses:
//   • rain-core-ios   — vendor-free port + registry + Rain domain logic + the Turnkey adapter
//   • rain-portal-ios — the Portal MPC adapter (depends on rain-core-ios + PortalSwift)
//   • rain-privy-ios  — the Privy embedded-key adapter (skeleton)
//
// New integrations should depend on the specific provider package(s) they need — see each
// package's own Package.swift. This root package is a **migration umbrella**: it vends a
// `RainSDK` library that re-exports `RainCore` + `RainPortal`, so `import RainSDK` keeps
// resolving. Module-level compatibility only — v2 replaces the 1.x `RainSDKManager` entry point
// with `RainSdk.builder()` (source-breaking; see README "Migrating from 1.x"). It will be
// deprecated once clients have moved to the per-provider modules.

let package = Package(
  name: "RainSDK",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "RainSDK",
      targets: ["RainSDK"]
    ),
  ],
  dependencies: [
    .package(path: "rain-core-ios"),
    .package(path: "rain-portal-ios"),
  ],
  targets: [
    .target(
      name: "RainSDK",
      dependencies: [
        .product(name: "RainCore", package: "rain-core-ios"),
        .product(name: "RainPortal", package: "rain-portal-ios"),
      ]
    ),
    .testTarget(
      name: "RainSDKTests",
      dependencies: ["RainSDK"]
    ),
  ]
)
