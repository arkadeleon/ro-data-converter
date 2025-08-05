// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ro-data-converter",
    platforms: [
        .macOS(.v13),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.6.0"),
        .package(url: "https://github.com/arkadeleon/swift-lua.git", branch: "master"),
    ],
    targets: [
        .executableTarget(
            name: "ro-data-converter",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Lua", package: "swift-lua"),
            ],
            resources: [
                .copy("Lua/dkjson.lua"),
            ]
        ),
    ]
)
