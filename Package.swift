// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DynamicWallpaperStudio",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "DynamicWallpaperStudio",
            targets: ["DynamicWallpaperStudio"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "DynamicWallpaperStudio",
            dependencies: [],
            path: "Sources/DynamicWallpaperStudio",
            resources: [],
            linkerSettings: [
                .linkedFramework("IOKit"),
                .linkedFramework("AVFoundation"),
                .linkedFramework("WebKit")
            ]
        )
    ]
)
