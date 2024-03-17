// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

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
        .package(url: "https://github.com/scade-platform/SCADE", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "EasySCADE",
            dependencies: ["ScadeExtensions", "SCADE"],
            exclude: ["Sources/EasySCADE/Generated"]),
        .testTarget(
            name: "EasySCADETests",
            dependencies: ["EasySCADE"]),
    ]
)
