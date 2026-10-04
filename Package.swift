// swift-tools-version: 5.9
import PackageDescription
let package = Package(name: "sshot", platforms: [.macOS(.v14)], products: [.executable(name: "sshot", targets: ["sshot"]),.executable(name:"sshot-fixture",targets:["sshot-fixture"])], targets: [.target(name: "CaptureCore"), .executableTarget(name: "sshot", dependencies: ["CaptureCore"]),.executableTarget(name:"sshot-fixture"), .testTarget(name: "CaptureCoreTests", dependencies: ["CaptureCore"])])
