// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "focus-manager",
    platforms: [.macOS(.v11)],
    products: [
        .library(name: "FocusManager", targets: ["FocusManager"])
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "FocusManager", dependencies: [])
    ]
)
