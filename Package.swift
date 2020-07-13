// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "RequestsCombine",
    platforms: [.iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macOS(.v10_15)],
    products: [
        .library(
            name: "RequestsCombine",
            targets: ["RequestsCombine"]),
    ],
    targets: [
        .target(
            name: "RequestsCombine",
            dependencies: []),
        .testTarget(
            name: "RequestsCombineTests",
            dependencies: ["RequestsCombine"]),
    ]
)
