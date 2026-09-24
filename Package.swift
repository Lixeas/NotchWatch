// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NotchWatch",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "NotchWatch", targets: ["NotchWatch"])
    ],
    targets: [
        .executableTarget(
            name: "NotchWatch",
            path: "NotchWatch",
            resources: [
                .copy("Resources/Fonts")
            ]
        ),
        .testTarget(
            name: "NotchWatchTests",
            dependencies: ["NotchWatch"],
            path: "NotchWatchTests"
        )
    ]
)
