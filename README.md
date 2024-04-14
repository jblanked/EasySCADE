# EasySCADE

EasySCADE aims to simplify SCADE mobile app development by providing a set of utilities and wrappers that make it easier to work with the SCADE framework. This library is designed to streamline your development process, allowing you to focus more on building your app and less on boilerplate code.

## Prerequisites

Before you begin, ensure you have met the following requirements:
- macOS system.
- Swift 5.9 or later installed.
- SCADE SDK installed. Follow the installation guide at [SCADE's GitHub repository](https://github.com/scade-platform/SCADE).

## Getting Started

To integrate EasySCADE into your SCADE mobile app project, follow these simple steps:

### Step 1: Install SCADE

Ensure you have SCADE installed on your system. You can find the installation instructions at [https://github.com/scade-platform/SCADE](https://github.com/scade-platform/SCADE).

### Step 2: Add EasySCADE as a Dependency

Open your SCADE project's `Package.swift` file and add EasySCADE to your project's dependencies:

```swift
import PackageDescription
import Foundation

let SCADE_SDK = ProcessInfo.processInfo.environment["SCADE_SDK"] ?? ""

let package = Package(
    name: "YourProjectName",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "YourProjectName",
            type: .static,
            targets: [
                "YourProjectName"
            ]
        )
    ],
    dependencies: [
        // Add EasySCADE as a dependency
        .package(url: "https://github.com/jblanked/EasySCADE", .branch("main"))
    ],
    targets: [
        .target(
            name: "YourProjectName",
            dependencies: ["EasySCADE"]),
            exclude: ["main.page"],
            swiftSettings: [
                .unsafeFlags(["-F", SCADE_SDK], .when(platforms: [.macOS, .iOS])),
                .unsafeFlags(["-I", "\(SCADE_SDK)/include"], .when(platforms: [.android])),
            ]
    ]
)
```

Replace `YourProjectName` with your project name.


### Step 3: Add SQLITE3 as a Library

Download the `lib` folder from [https://github.com/6vedant/SQLiteScadeExample/tree/master/lib](https://github.com/6vedant/SQLiteScadeExample/tree/master/lib) and place it directly in your project directory.

Then, open your SCADE project's `build.yaml` file and add SQLite3 as a linked library in the `android` section:

```swift
android:
  name: YourProjectName
  id: com.scade.YourProjectName
  version-name: 1.0.0
  version-code: 1
  build-type: Debug
  key-store-properties:
  google-api-key:
  manifest-file:
  permissions: [INTERNET,BLUETOOTH,CAMERA,POST_NOTIFICATIONS] // add these permissions as well
  armeabi-v7a:
    output: 
    product-path: 
    extra-args:
    search-paths: []
    linked-libs: [sqlite3] // add sqlite3
  arm64-v8a:
    output: 
    product-path: 
    extra-args:
    search-paths: []
    linked-libs: [sqlite3] // add sqlite3
  x86:
    output: 
    product-path: 
    extra-args:
    search-paths: []
    linked-libs: [sqlite3] // add sqlite3
  x86_64:
    output: 
    product-path: 
    extra-args:
    search-paths: []
    linked-libs: [sqlite3] // add sqlite3
  intent-filters:
    - action:
      scheme:
      categories: []
  icons:
    mdpi:
    hdpi:
    xhdpi:
    xxhdpi:

```



### Step 4: Import EasySCADE

Now that you have added EasySCADE as a dependency, you can start using it in your project. Simply import EasySCADE in your Swift files:

```swift
import EasySCADE
```

### Step 5: Start Using EasySCADE

You are now ready to simplify your SCADE app development with EasySCADE! Check the [Usage](#usage) section below for examples on how to use EasySCADE in your project.

## Usage

Here are some examples of how EasySCADE can be used in your SCADE applications:

```swift
// Text Label
let textLabel: SCDWidgetsWidget = EasySCDTextLabel("Your Text")

// Image
let image: SCDWidgetsImage = EasySCDImage("Assets/YourImage.png")

// ImageURL with caching
let image: SCDWidgetsImage = EasySCDImageCache("yourKey", "yourImageURL")

// Button
let button: SCDWidgetsButton = EasySCDButton("Button")

// Navigation Bar
let navigationBar: SCDWidgetsWidget = EasySCDNavigationBar()

// Check Box
let checkBox: SCDWidgetsCheckbox = EasySCDCheckbox()

// colors
let white: SCDGraphicsRGB = EasyColor.white
let black: SCDGraphicsRGB = EasyColor.black
let blue: SCDGraphicsRGB = EasyColor.blue
let red: SCDGraphicsRGB = EasyColor.red

// Alert
EasyAlert(title: "Your Title", message: "Your Alert Message")

// Loading Spinner
EasySpinner(true)

// VStack
let vStack: SCDWidgetsContainer = EasySCDVStack(
	[
		textLabel,
		button
	]
)

// alternative VStack
self.vStack {
	textLabel
	button
}

// alternative VStack 2
let container: SCDWidgetsContainer = SCDWidgetsContainer()

container.vStack {
	textLabel
	button
}

// HStack
let hStack: SCDWidgetsContainer = EasySCDHStack(
	[
		textLabel,
		button
	]
)

// alternative HStack
self.hStack {
	textLabel
	button
}

// alternative HStack 2
let container: SCDWidgetsContainer = SCDWidgetsContainer()

container.hStack {
	textLabel
	button
}	
```



## License

EasySCADE is released under the MIT License. See [LICENSE](LICENSE) for details.
