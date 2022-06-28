// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TweakAccessorGenerator",
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.2")
    ],
    targets: [
        .executableTarget(
            name: "TweakAccessorGenerator",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "TweakAccessorGeneratorTests",
            dependencies: ["TweakAccessorGenerator"],
            path: "Tests",
            resources: [
                .process("Resources")
            ]
        ),
    ]
)