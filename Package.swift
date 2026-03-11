// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TermBar",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "TermBarKit", targets: ["TermBarKit"]),
        .executable(name: "TermBar", targets: ["TermBar"])
    ],
    targets: [
        .target(
            name: "TermBarKit",
            path: "Sources/TermBar"
        ),
        .executableTarget(
            name: "TermBar",
            dependencies: ["TermBarKit"],
            path: "Sources/TermBarApp"
        )
    ]
)
