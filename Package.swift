// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MJExtension",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v8)
    ],
    products: [
       .library(
        name: "MJExtension",
        targets: ["MJExtension"])
    ],
    targets: [
       .target(
           name: "MJExtension",
           path: "MJExtension"
       )
    ]
)
