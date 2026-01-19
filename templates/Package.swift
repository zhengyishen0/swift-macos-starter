// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "__APP_NAME__",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "__APP_NAME__Lib", targets: ["__APP_NAME__Lib"])
    ],
    dependencies: [
        // Sparkle for auto-updates (uncomment to enable)
        // .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.6.0"),
    ],
    targets: [
        // Uncomment if using external xcframework:
        // .binaryTarget(
        //     name: "MyFramework",
        //     path: "Frameworks/MyFramework.xcframework"
        // ),
        .target(
            name: "__APP_NAME__Lib",
            dependencies: [
                // "MyFramework",
                // .product(name: "Sparkle", package: "Sparkle"),
            ],
            path: "__APP_NAME__",
            resources: [.copy("Resources")]
        )
    ]
)
