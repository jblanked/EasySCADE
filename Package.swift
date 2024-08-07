// swift-tools-version:5.9
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
        .package(url: "https://github.com/supabase-community/supabase-swift.git", branch: "main"),
        .package(url: "https://github.com/devicekit/DeviceKit.git", branch: "master"),
        .package(url: "https://github.com/OpenCombine/OpenCombine.git", branch: "master"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "EasySCADE",
            dependencies: ["ScadeExtensions",
            .product(name: "Android", package: "swift-android", condition: .when(platforms: [.android])),
            .product(name: "AndroidOS", package: "swift-android", condition: .when(platforms: [.android])),
            .product(name: "AndroidView", package: "swift-android", condition: .when(platforms: [.android])),
            .product(name: "AndroidNFC", package: "swift-android", condition: .when(platforms: [.android])),
            .product(name: "AndroidApp", package: "swift-android", condition: .when(platforms: [.android])),
            .product(name: "AndroidContent", package: "swift-android", condition: .when(platforms: [.android])), 
            .product(name: "AndroidMedia", package: "swift-android", condition: .when(platforms: [.android])), 
            .product(name: "AndroidBluetooth", package: "swift-android", condition: .when(platforms: [.android])), 
            .product(name: "AndroidGraphics", package: "swift-android", condition: .when(platforms: [.android])), 
            .product(name: "AndroidLocation", package: "swift-android", condition: .when(platforms: [.android])),
            .product(name: "Supabase", package: "supabase-swift", condition: .when(platforms: [.iOS])),
            .product(name: "DeviceKit", package: "DeviceKit", condition: .when(platforms: [.iOS])),
            .product(name: "OpenCombine", package: "OpenCombine"),
            .product(name: "OpenCombineDispatch", package: "OpenCombine"),
            .product(name: "OpenCombineFoundation", package: "OpenCombine")
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
