// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "bm_flutter_networking",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "bm-flutter-networking", targets: ["bm_flutter_networking"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "bm_flutter_networking",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
