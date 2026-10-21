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
        // iOS interview prep: one playground file per quiz topic (see interview/README.md).
        .target(
            name: "Interview",
            path: "interview",
            exclude: ["README.md"]
        ),
    ],
    swiftLanguageModes: [.v5]
)
