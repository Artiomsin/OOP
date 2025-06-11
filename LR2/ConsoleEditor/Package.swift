// swift-tools-version: 5.6
import PackageDescription

let package = Package(
    name: "ConsoleEditor",
    platforms: [
        .macOS(.v12) // Укажи минимальную версию macOS
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0")
    ],
    targets: [
        .executableTarget(
            name: "ConsoleEditor",
            dependencies: [
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                                

            ],
            resources: [
                .process("GoogleService-Info.plist")
            ]
        ),
            .testTarget(
            name: "ConsoleEditorTests",
            dependencies: ["ConsoleEditor"]
        ),
    ]
)


/*
// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ConsoleEditor",
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "ConsoleEditor"),
    ]
)
*/
