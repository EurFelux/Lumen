// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Lumen",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "Lumen", targets: ["Lumen"])
    ],
    targets: [
        .executableTarget(
            name: "Lumen",
            path: "Lumen/Sources",
            resources: [
                .process("Resources")
            ],
            linkerSettings: [
                .linkedFramework("IOKit"),
                .linkedFramework("AppKit")
            ]
        )
    ]
)
