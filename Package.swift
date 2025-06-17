// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "WakeyWakey",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(name: "WakeyWakey", targets: ["WakeyWakey"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "WakeyWakey",
            dependencies: [],
            path: "WakeyWakey",
            resources: [
                .process("Assets.xcassets"),
                .process("Info.plist")
            ]
        ),
        .testTarget(
            name: "WakeyWakeyTests",
            dependencies: ["WakeyWakey"],
            path: "WakeyWakeyTests"
        )
    ]
)
