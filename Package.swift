// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SwiftLibgd",
    products: [
        .library(
            name: "SwiftLibgd",
            targets: ["SwiftLibgd"]
        ),
    ],
    targets: [
        .systemLibrary(
            name: "gd",
            pkgConfig: "gdlib",
            providers: [
                .brew(["gd"]),
                .apt(["libgd-dev"])
            ]
        ),
        .target(
            name: "SwiftLibgd",
            dependencies: ["gd"],
            path: "Sources"
        ),
        .testTarget(
            name: "SwiftLibgdTests",
            dependencies: ["SwiftLibgd"]
        ),
    ]
)
