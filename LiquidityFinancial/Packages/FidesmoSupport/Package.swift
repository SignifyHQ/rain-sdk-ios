// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FidesmoSupport",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "FidesmoSupport",
            targets: ["FidesmoSupport"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/fidesmo/fidesmo-ios-sdk.git", from: "1.1.0"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.5.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "FidesmoSupport",
            dependencies: [
                .product(name: "FidesmoCore", package: "fidesmo-ios-sdk"),
                .product(name: "CoreNfcBridge", package: "fidesmo-ios-sdk"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift")
            ]
        ),
        .testTarget(
            name: "FidesmoSupportTests",
            dependencies: ["FidesmoSupport"]
        ),
    ]
) 