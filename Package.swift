// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

let SCADE_SDK = ProcessInfo.processInfo.environment["SCADE_SDK"] ?? ""

let package = Package(
    name: "EasySCADE",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "EasySCADE",
            targets: ["EasySCADE"]),
    ],
    dependencies: [
        .package(url: "https://github.com/scade-platform/ScadeExtensions", branch: "main"),
        .package(url: "https://github.com/scade-platform/swift-android.git", branch: "android/24"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "EasySCADE",
            dependencies: ["ScadeExtensions",
            .product(name: "Android", package: "swift-android", condition: .when(platforms: [.android])),
                 .product(name: "AndroidOS", package: "swift-android", condition: .when(platforms: [.android])),
                  .product(name: "AndroidApp", package: "swift-android", condition: .when(platforms: [.android])),
                   .product(name: "AndroidContent", package: "swift-android", condition: .when(platforms: [.android])), 
            ],
            exclude: ["Sources/EasySCADE/Generated"],
            swiftSettings: [
                .unsafeFlags(["-F", SCADE_SDK], .when(platforms: [.macOS, .iOS])),
                .unsafeFlags(["-I", "\(SCADE_SDK)/include"], .when(platforms: [.android])),
            ]),
        .testTarget(
            name: "EasySCADETests",
            dependencies: ["EasySCADE"]),
    ]
)
