// swift-tools-version: 5.7

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "dotfiles",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .iOSApplication(
            name: "dotfiles",
            targets: ["AppModule"],
            bundleIdentifier: "com.dotfiles.juliofruta.app",
            teamIdentifier: "V9QPA276C7",
            displayVersion: "0.1",
            bundleVersion: "18",
            appIcon: .asset("AppIcon"),
            accentColor: .presetColor(.mint),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ],
            capabilities: [
            ],
            appCategory: .utilities
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .exact("0.45.0"))
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Dependencies", package: "swift-composable-architecture")
            ],
            path: ".",
            resources: [
                .process("Resources")
            ]
        )
    ]
)