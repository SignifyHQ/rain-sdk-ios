// swift-tools-version: 6.1
import PackageDescription

let package = Package(
  name: "RainCore",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "RainCore",
      targets: ["RainCore"]
    ),
  ],
  dependencies: [
    // Turnkey is bundled inside core for now (the Turnkey adapter lives here). No Portal / Privy.
    .package(url: "https://github.com/tkhq/swift-sdk.git", exact: "4.0.0"),
    .package(url: "https://github.com/Boilertalk/Web3.swift.git", exact: "0.8.8"),
    .package(url: "https://github.com/web3swift-team/web3swift.git", from: "3.3.2"),
    .package(url: "https://github.com/dagronf/QRCode", exact: "28.0.2")
  ],
  targets: [
    .target(
      name: "RainCore",
      dependencies: [
        .product(name: "TurnkeySwift", package: "swift-sdk"),
        .product(name: "TurnkeyHttp", package: "swift-sdk"),
        .product(name: "TurnkeyTypes", package: "swift-sdk"),
        .product(name: "QRCode", package: "QRCode"),
        .product(name: "Web3", package: "Web3.swift"),
        .product(name: "Web3PromiseKit", package: "Web3.swift"),
        .product(name: "Web3ContractABI", package: "Web3.swift"),
        .product(name: "web3swift", package: "web3swift")
      ],
      resources: [
        .process("Resources")
      ]
    ),
    .testTarget(
      name: "RainCoreTests",
      dependencies: ["RainCore"]
    ),
  ]
)
