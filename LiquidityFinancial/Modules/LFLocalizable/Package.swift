// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LFLocalizable",
    defaultLocalization: "en",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "AvalancheLocalizable",
            targets: ["AvalancheLocalizable"]),
        .library(
          name: "CardanoLocalizable",
          targets: ["CardanoLocalizable"]),
        .library(
          name: "LFLocalizable",
          targets: ["LFLocalizable"]),
    ],
    dependencies: [
      .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", from: "6.6.2")
    ],
    targets: [
        .target(
            name: "LFLocalizable",
            dependencies: [],
            resources: [
              .process("Resources")
            ],
            plugins: [
              .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin")
            ]),
        .target(
          name: "AvalancheLocalizable",
          dependencies: [],
          resources: [
            .process("Resources")
          ],
          plugins: [
            .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin")
          ]),
        .target(
          name: "CardanoLocalizable",
          dependencies: [],
          resources: [
            .process("Resources")
          ],
          plugins: [
            .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin")
          ])
    ]
)
