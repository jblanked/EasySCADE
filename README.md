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


### Step 3: Import EasySCADE

Now that you have added EasySCADE as a dependency, you can start using it in your project. Simply import EasySCADE in your Swift files:

```swift
import EasySCADE
```

### Step 4: Start Using EasySCADE

You are now ready to simplify your SCADE app development with EasySCADE! Check the [Usage](#usage) section below for examples on how to use EasySCADE in your project.

## Usage

Here are some examples of how EasySCADE can be used in your SCADE applications:

```swift
// Text Label
let textLabel: SCDWidgetsWidget = EasySCDTextLabel("Your Text")

// Textbox
let textBox: SCDWidgetsTextbox = EasySCDTextBox("Placeholder")

// Textbox Form
let textBoxForm: SCDWidgetsWidget = EasySCDTextForm(
    [
        EasySCDTextBoxForm(
            title: "Your Title",
            textbox: textBox // from above
        )
    ]
)

// Image with caching
let image: SCDWidgetsImage = EasySCDImage("Assets/YourImage.png")

// ImageURL with caching
let image: SCDWidgetsImage = EasySCDImageURL("yourImageURL")

// Button
let button: SCDWidgetsButton = EasySCDButton("Button")

// Navigation Bar
let navigationBar: SCDWidgetsWidget = EasySCDNavigationBar()

// WebView/VideoView
let web: SCDWidgetsWebView = EasySCDWebView("https://www.github.com/jblanked/EasySCADE")

// Check Box
let checkBox: SCDWidgetsCheckbox = EasySCDCheckbox()

// Spacer
let spacer: SCDWidgetsWidget = EasySCDSpacer()

// Separator
let separator: SCDWidgetsWidget = EasySCDSeperator()


// Screen Info
screenInfo.screenSize.height // Screen Height
screenInfo.screenSize.width // Screen Width
screenInfo.statusBarVisible // boolean 
screenInfo.statusBarsize.height // Status Bar Height
screenInfo.statusBarsize.width // Status Bar Width


// App Storage
appStorage.write(key: "yourKey", value: "Your Value")  // save value

appStorage.deleteAllKeys() // delete all keys

appStorage.delete(key: "yourKey") // delete key

if let yourValue = appStorage.read(key: "yourKey") // get value from key
{
    print(yourValue)
}


// colors
let white: SCDGraphicsRGB = EasyColor.white
let black: SCDGraphicsRGB = EasyColor.black
let blue: SCDGraphicsRGB = EasyColor.blue
let red: SCDGraphicsRGB = EasyColor.red

// Alert
EasyAlert(title: "Your Title", message: "Your Alert Message")

// Loading Spinner
EasySpinner(true)

// Swipe Gesture
EasySwipeGesture(
    self.page,
    .left
)

// Swipe Gesture
image.swipeGesture({ self.navigation!.go(page: "main.page")  }, .right)


// Card
let card: SCDWidgetsContainer = EasySCDCard(
    path: "Assets/YourBackgroundImage.png",
    title: "Header title",
    description: "Body"
)

// Swipe Gesture
card.swipeGesture({ self.navigation!.go(page: "main.page")  }, .left)


// List
let list: SCDWidgetsContainer = EasySCDList(
    [
        EasySCDListElement(item: "Value1"),
        EasySCDListElement(item: "Value2"),
        EasySCDListElement(item: "Value3")
    ]
)

// VStack
let vStack: SCDWidgetsContainer = EasySCDVStack(
	[
		textLabel, // from above
		button // from above
	]
)

// alternative VStack
self.vStack {
	textLabel // from above
	button // from above
}

// alternative VStack 2
let container: SCDWidgetsContainer = SCDWidgetsContainer()

container.vStack {
	textLabel // from above
	button // from above
}

// HStack
let hStack: SCDWidgetsContainer = EasySCDHStack(
	[
		textLabel, // from above
		button // from above
	]
)

// alternative HStack
self.hStack {
	textLabel // from above
	button // from above
}

// alternative HStack 2
let container: SCDWidgetsContainer = SCDWidgetsContainer()

container.hStack {
	textLabel // from above
	button // from above
}	
```



## License

EasySCADE is released under the MIT License. See [LICENSE](LICENSE) for details.
