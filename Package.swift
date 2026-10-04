// swift-tools-version: 5.9
import PackageDescription
let package = Package(
    name: "shotclip",
    defaultLocalization: "en",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "shotclip", targets: ["shotclip"]),
        .executable(name: "shotclip-fixture", targets: ["shotclip-fixture"])
    ],
    dependencies: [.package(url: "https://github.com/sparkle-project/Sparkle", exact: "2.10.0")],
    targets: [
        .target(name: "CaptureCore"),
        .executableTarget(
            name: "shotclip",
            dependencies: ["CaptureCore", .product(name: "Sparkle", package: "Sparkle")],
            resources: [.process("Resources")],
            linkerSettings: [.unsafeFlags(["-Xlinker", "-rpath", "-Xlinker", "@executable_path/../Frameworks"])]
        ),
        .executableTarget(name: "shotclip-fixture"),
        .testTarget(name: "CaptureCoreTests", dependencies: ["CaptureCore"])
    ]
)
