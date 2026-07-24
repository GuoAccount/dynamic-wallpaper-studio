// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DynamicWallpaper",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "DynamicWallpaper",
            targets: ["DynamicWallpaper"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "DynamicWallpaper",
            dependencies: [],
            path: "Sources/DynamicWallpaper",
            resources: [],
            linkerSettings: [
                .linkedFramework("IOKit"),
                .linkedFramework("AVFoundation"),
                .linkedFramework("WebKit")
            ]
        )
    ]
)
