// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "sprig_flutter_plugin",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        // The product name must be the dash-cased plugin name so Flutter's
        // Swift Package Manager integration can discover it.
        .library(name: "sprig-flutter-plugin", targets: ["sprig_flutter_plugin"])
    ],
    dependencies: [
        // Sprig iOS SDK, consumed via Swift Package Manager instead of CocoaPods.
        // Pinned to the exact release that the CocoaPods dependency previously used.
        .package(
            url: "https://github.com/UserLeap/userleap-ios-sdk-releases.git",
            exact: "4.33.0"
        )
    ],
    targets: [
        .target(
            name: "sprig_flutter_plugin",
            dependencies: [
                .product(name: "UserLeapKit", package: "userleap-ios-sdk-releases")
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
