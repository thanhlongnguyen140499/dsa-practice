// swift-tools-version: 6.0
// Open this folder in Xcode; every file in solutions/ has a #Playground block
// that runs in the canvas (Editor → Canvas, or ⌥⌘↩).
import PackageDescription

let package = Package(
    name: "DSA",
    platforms: [.macOS(.v15)],
    targets: [
        .target(
            name: "Solutions",
            path: "solutions"
        ),
    ],
    swiftLanguageModes: [.v5]
)
