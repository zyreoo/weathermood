// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WeatherMood",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "WeatherMood",
            targets: ["WeatherMood"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "WeatherMood",
            dependencies: [],
            resources: [
                .process("Assets.xcassets")
            ],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals")
            ]
        )
    ]
)
