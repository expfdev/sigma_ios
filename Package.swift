// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "SigmaSDK",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(name: "SigmaSDK", targets: ["SigmaSDK"])
    ],
    targets: [
        .binaryTarget(name: "SigmaSDK", path: "SigmaSDK.xcframework")
    ]
)
