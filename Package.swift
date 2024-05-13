// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RexselKernel",
    defaultLocalization: "en",
    products: [
        .library(
            name: "RexselKernel",
            targets: ["RexselKernel"]),
    ],
    targets: [
        .target(
            name: "RexselKernel",
            dependencies: [],
            resources: [
                .process( "Resources" )
            ],
            swiftSettings: [
                .define("REXSEL_LOGGING"),
            ] ),

        .testTarget(
            name: "RexselKernelTests",
            dependencies: ["RexselKernel"]),
    ]
)
