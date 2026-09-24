// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ClaudeNotchBar",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "ClaudeNotchBar", targets: ["ClaudeNotchBar"])
    ],
    targets: [
        .executableTarget(
            name: "ClaudeNotchBar",
            path: "ClaudeNotchBar",
            resources: [
                .copy("Resources/Fonts")
            ]
        ),
        .testTarget(
            name: "ClaudeNotchBarTests",
            dependencies: ["ClaudeNotchBar"],
            path: "ClaudeNotchBarTests"
        )
    ]
)