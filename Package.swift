// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "GeminiChat",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "GeminiChat",
            path: "Sources/GeminiChat"
        )
    ]
)
