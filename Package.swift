// swift-tools-version: 5.9
import PackageDescription

// This package tests the shared, platform-independent app logic.
// Open Thiruppavai.xcodeproj to build the actual macOS application.
let package = Package(
    name: "ThiruppavaiCore",
    platforms: [.macOS(.v13), .iOS(.v17)],
    products: [.library(name: "ThiruppavaiCore", targets: ["ThiruppavaiCore"])],
    targets: [
        .target(name: "ThiruppavaiCore", path: "Shared/Core", resources: [.process("Resources")]),
        .testTarget(name: "ThiruppavaiCoreTests", dependencies: ["ThiruppavaiCore"], path: "Tests")
    ]
)
