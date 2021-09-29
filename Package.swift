// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "MJExtension",
    products: [
        .library(name: "MJExtension", targets: ["MJExtension"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MJExtension",
            dependencies: [],
            path: "MJExtension",
            exclude: ["Info.plist"],
            publicHeadersPath: ".",
            cxxSettings: [
                .headerSearchPath("."),
            ]
        ),
        // Mixed languages are not supported now. Go MJExtension project to see tests.
//        .testTarget(
//            name: "MJExtensionTests",
//            dependencies: ["MJExtension"],
//            path: "MJExtensionTests",
//            exclude: ["Info.plist"]
//        )
    ]
)
