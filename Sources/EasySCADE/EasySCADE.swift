// Import necessary modules and conditionally import platform-specific ones
import ScadeKit
import Dispatch
import Foundation
import ScadeUI

#if os(iOS)
import UIKit 
import SwiftUI
#endif

#if os(Android)
import AndroidView
import Java
import Android
import AndroidApp
import AndroidContent
import AndroidOS
let easyProgress: ProgressDialog = ProgressDialog(context: Application.currentActivity!)
#endif

//import SQLite

// public class EasyAppStorage {
    
//     private let db: Connection
//     private let keyValueTable = Table("key_value_store")
//     private let key = Expression<String>("key")
//     private let value = Expression<String>("value")
    
//     // Initialize the database connection
//     public init() {
//         do {
//             let path = NSHomeDirectory() + "/data.db"
//             db = try Connection(path)
//             try createTable()
//         } catch {
//             fatalError("Failed to initialize database connection: \(error)")
//         }
//     }
    
//     // Create the key-value table
//     private func createTable() throws {
//         try db.run(keyValueTable.create(ifNotExists: true) { t in
//             t.column(key, primaryKey: true)
//             t.column(value)
//         })
//     }
    
//     // Write a key-value pair
//     public func write(key: String, value: String) {
//         do {
//             let insert = keyValueTable.insert(or: .replace, self.key <- key, self.value <- value)
//             try db.run(insert)
//         } catch {
//             print("Failed to write key-value: \(error)")
//         }
//     }
    
//     // Read a value by key
//     public func read(key: String) -> String? {
//         do {
//             if let row = try db.pluck(keyValueTable.filter(self.key == key)) {
//                 return row[self.value]
//             }
//         } catch {
//             print("Failed to read key: \(error)")
//         }
//         return nil
//     }
    
//     // Delete a key-value pair
//     public func delete(key: String) {
//         do {
//             let row = keyValueTable.filter(self.key == key)
//             try db.run(row.delete())
//         } catch {
//             print("Failed to delete key: \(error)")
//         }
//     }

// 	// Delete all key-value pairs
// 	public func deleteAllKeys() {
// 		do {
// 			try db.run(keyValueTable.delete())
// 		} catch {
// 			print("Failed to delete all keys: \(error)")
// 		}
// 	}
// }

public class EasyAppStorage {
    
    #if os(iOS)
    // iOS UserDefaults as the storage medium
    #elseif os(Android)
    // Android SharedPreferences as the storage medium
    private var sharedPreferences: AndroidContent.SharedPreferences?
    #endif
    
    public init() {
        #if os(Android)
        sharedPreferences = Application.currentActivity?.getSharedPreferences(name: "EasySCADE", mode: 0)
        #endif
    }
    
    public func write(key: String, value: String) {
        #if os(Android)
        let editor = sharedPreferences?.edit()
        editor?.putString(key: key, value: value)
        editor?.apply()
        #else
        UserDefaults.standard.set(value, forKey: key)
        #endif
    }
    
    public func read(key: String) -> String? {
        #if os(Android)
        return sharedPreferences?.getString(key: key, defValue: "")
        #else
        return UserDefaults.standard.string(forKey: key)
        #endif

    }
    
    public func delete(key: String) {
        #if os(Android)
        let editor = sharedPreferences?.edit()
        editor?.remove(key: key)
        editor?.apply()
        #else
        UserDefaults.standard.removeObject(forKey: key)
        #endif
    }
    
    public func deleteAllKeys() {
        #if os(Android)
        let editor = sharedPreferences?.edit()
        editor?.clear()
        editor?.apply()
        #else
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }
        #endif
    }
}


public let appStorage: EasyAppStorage = EasyAppStorage()

// class to store screen information
public class EasyScreenInfo: EObject {
    public var screenSize: CGSize
    public var statusBarVisible: Bool
    public var statusBarsize: CGSize
    
    public init(screenSize: CGSize, statusBarVisible: Bool, statusBarsize: CGSize) {
        self.screenSize = screenSize
        self.statusBarsize = statusBarsize
        self.statusBarVisible = statusBarVisible
    }
}

private func getWindowScreenSize() -> EasyScreenInfo {
    let size = SCDRuntime.system.getScreenSize()
    let statusBarVisible = SCDRuntime.system.statusBarVisible
    let statusBarsize = SCDRuntime.system.getScreenSafeArea()
    
    return EasyScreenInfo(
        screenSize: CGSize(width: size!.width, height: size!.height),
        statusBarVisible: statusBarVisible,
        statusBarsize: CGSize(width: statusBarsize!.bounds.width, height: statusBarsize!.bounds.height)
    )
}

// stores the screen information
public let screenInfo: EasyScreenInfo = getWindowScreenSize()

public class EasyVStack {
    private var widgets: [SCDWidgetsWidget] = []
    private let spacing: Int
    
    // Assume widgets are passed directly to the initializer
    public init(spacing: Int = 10, widgets: [SCDWidgetsWidget]) {
        self.spacing = spacing
        self.widgets = widgets
    }
    
    
    // Simplified for direct widget array initialization
    public convenience init(spacing: Int = 10, @WidgetArrayBuilder _ builder: () -> [SCDWidgetsWidget]) {
        self.init(spacing: spacing, widgets: builder())
    }
    
    // Function to layout the widgets vertically
    public func layout(in parentWidget: SCDWidgetsContainer) {
        var yOffset = 0
        
	for element in self.widgets {
		let tempContainer = SCDWidgetsContainer()
		tempContainer.location = SCDGraphicsPoint(x: Int(element.location.x), y: yOffset)
		tempContainer.size = SCDGraphicsDimension(width: Int(element.size.width), height: Int(element.size.height))
		yOffset += Int(element.size.height) + spacing
		tempContainer.children.append(element)
		parentWidget.children.append(tempContainer)
	}

	parentWidget.size = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: yOffset)
    }
}

public class EasyHStack {
	private var widgets: [SCDWidgetsWidget] = []
	private let spacing: Int
	
	// Assume widgets are passed directly to the initializer
	public init(spacing: Int = 10, widgets: [SCDWidgetsWidget]) {
		self.spacing = spacing
		self.widgets = widgets
	}
	
	// Simplified for direct widget array initialization
	public convenience init(spacing: Int = 10, @WidgetArrayBuilder _ builder: () -> [SCDWidgetsWidget]) {
		self.init(spacing: spacing, widgets: builder())
	}
	
	// Function to layout the widgets horizontally
	public func layout(in parentWidget: SCDWidgetsContainer) {
		var xOffset = 0
		
	for element in self.widgets {
		let tempContainer = SCDWidgetsContainer()
		tempContainer.location = SCDGraphicsPoint(x: xOffset, y: Int(element.location.y))
		tempContainer.size = SCDGraphicsDimension(width: Int(element.size.width), height: Int(element.size.height))
		xOffset += Int(element.size.width) + spacing
		tempContainer.children.append(element)
		parentWidget.children.append(tempContainer)
	}

	parentWidget.size = SCDGraphicsDimension(width: xOffset, height: Int(screenInfo.screenSize.height))
	}
}

@resultBuilder
public struct WidgetArrayBuilder {
    public static func buildBlock(_ components: SCDWidgetsWidget...) -> [SCDWidgetsWidget] {
        components
    }
}

extension SCDLatticePageAdapter {

	public func append(_ widget: SCDWidgetsWidget) {
		self.page?.children.append(widget)
	}
	
	public var screenSize: CGSize {
		return CGSize(width: screenInfo.screenSize.width, height: screenInfo.screenSize.height)
	}

    // A method to lay out EasyVStack on the current page
    public func vStack(@WidgetArrayBuilder _ builder: () -> [SCDWidgetsWidget], _ spacing: Int = 10) {
        let st = EasyVStack.init(spacing: spacing, widgets: builder())
        st.layout(in: self.page!)
    }    

	// A method to lay out EasyHStack on the current page
	public func hStack(@WidgetArrayBuilder _ builder: () -> [SCDWidgetsWidget], _ spacing: Int = 10) {
		let st = EasyHStack.init(spacing: spacing, widgets: builder())
		st.layout(in: self.page!)
	}

	public func navigateTo(_ page: String = "main.page") {
		DispatchQueue.main.async { self.navigation?.go(page: page) }
	}

	public func scrollbar(
			_ onScroll: @escaping () -> Void = { },
			onPageEnter: @escaping () -> Void = { },
			onPageExit: @escaping () -> Void = { }
		) {
		 EasySCDScrollbar(
			self.page!,
			self.page!,
			onScroll,
			onPageEnter: onPageEnter,
			onPageExit: onPageExit
		)	
		
	}

	public func swipeGesture(
			_ action: @escaping () -> Void = {  },
			_ direction: SCDSvgSwipeDirection = .right
		)  {
			EasySwipeGesture(self.page!, direction, action)
		}

}

extension SCDWidgetsWidget {
	public func swipeGesture(
			_ action: @escaping () -> Void = {  },
			_ direction: SCDSvgSwipeDirection = .right
		)  {
			EasySwipeGesture(self, direction, action)
		}
}

extension SCDWidgetsContainer {
	// A method to lay out EasyVStack in a container
	public func vStack(@WidgetArrayBuilder _ builder: () -> [SCDWidgetsWidget], _ spacing: Int = 10) {
		let st = EasyVStack.init(spacing: spacing, widgets: builder())
		st.layout(in: self)
	}

	// A method to lay out EasyHStack in a container
	public func hStack(@WidgetArrayBuilder _ builder: () -> [SCDWidgetsWidget], _ spacing: Int = 10) {
		let st = EasyHStack.init(spacing: spacing, widgets: builder())
		st.layout(in: self)
	}
}


// extension to SCDGraphicsRGB to make it Equatable
extension SCDGraphicsRGB: Equatable {
    public static func ==(lhs: SCDGraphicsRGB, rhs: SCDGraphicsRGB) -> Bool {
        return lhs.red == rhs.red && lhs.green == rhs.green && lhs.blue == rhs.blue
    }
}

// extension to SCDSvgRGBColor to make it Equatable
extension SCDSvgRGBColor: Equatable {
    public static func ==(lhs: SCDSvgRGBColor, rhs: SCDSvgRGBColor) -> Bool {
        return lhs.red == rhs.red && lhs.green == rhs.green && lhs.blue == rhs.blue
    }
}


// colors
public struct EasyColor {
	public static let white = SCDGraphicsRGB(red: 248, green: 248, blue: 248)
	public static let blue = SCDGraphicsRGB(red: 10, green: 132, blue: 255) // iOS blue
	public static let black = SCDGraphicsRGB(red: 0, green: 0, blue: 0)
	public static let green = SCDGraphicsRGB(red: 48, green: 209, blue: 88) // iOS green
	public static let red = SCDGraphicsRGB(red: 215, green: 0, blue: 21) // iOS red
	public static let gray = SCDGraphicsRGB(red: 199, green: 199, blue: 204) // iOS gray
	public static let yellow = SCDGraphicsRGB(red: 255, green: 214, blue: 10) // iOS yellow
	public static let orange = SCDGraphicsRGB(red: 255, green: 159, blue: 10) // iOS orange
	public static let purple = SCDGraphicsRGB(red: 191, green: 90, blue: 242) // iOS purple
	public static let pink = SCDGraphicsRGB(red: 255, green: 55, blue: 95) // iOS pink
}

// SVG colors
public struct EasySVGColor {
	public static let white = SCDColor.init(red: 248, green: 248, blue: 248)
	public static let blue = SCDColor.init(red: 10, green: 132, blue: 255)
	public static let black = SCDColor.init(red: 0, green: 0, blue: 0)
	public static let green = SCDColor.init(red: 48, green: 209, blue: 88) 
	public static let red = SCDColor.init(red: 215, green: 0, blue: 21)
	public static let gray = SCDColor.init(red: 199, green: 199, blue: 204) 
	public static let yellow = SCDColor.init(red: 255, green: 214, blue: 10)
	public static let orange = SCDColor.init(red: 255, green: 159, blue: 10)
	public static let purple = SCDColor.init(red: 191, green: 90, blue: 95)
	public static let pink = SCDColor.init(red: 255, green: 55, blue: 95)
}

// converting string SCDColor to SCDColor
public func EasySCDColor(_ color: String, _ defaultColor: SCDColor = SCDColor.white) -> SCDColor {
	switch color {
		case "SCDColor.white": return SCDColor.white
		case "SCDColor.red": return SCDColor.red
		case "SCDColor.green": return SCDColor.green
		case "SCDColor.black": return SCDColor.black
		case "SCDColor.pink": return SCDColor.pink
		case "SCDColor.orange": return SCDColor.orange
		case "SCDColor.blue": return SCDColor.blue
		case "SCDColor.gray": return SCDColor.gray
		case "SCDColor.yellow": return SCDColor.yellow
		case "SCDColor.purple": return SCDColor.purple	
		case "SCDColor.lightblue": return SCDColor.lightblue
		case "SCDColor.darkgray": return SCDColor.darkgray
		case "SCDColor.lightgreen": return SCDColor.lightgreen
		case "SCDColor.brown": return SCDColor.brown
		case "SCDColor.darkblue": return SCDColor.darkblue
		case "SCDColor.turquoise": return SCDColor.turquoise
		case "SCDColor.lightpink": return SCDColor.lightpink
		case "SCDColor.lightgray": return SCDColor.lightgray
		case "SCDColor.cyan": return SCDColor.cyan
		case "SCDColor.teal": return SCDColor.teal
	    case "SCDColor.darkgreen": return SCDColor.darkgreen
		case "SCDColor.darkred": return SCDColor.darkred
		case "SCDColor.darksalmon": return SCDColor.darksalmon
		case "SCDColor.darkorange": return SCDColor.darkorange
		case "SCDColor.firebrick": return SCDColor.firebrick
		case "SCDColor.deeppink": return SCDColor.deeppink
		case "SCDColor.lightsalmon": return SCDColor.lightsalmon
		case "SCDColor.darkturquoise": return SCDColor.darkturquoise
		case "SCDColor.greenyellow": return SCDColor.greenyellow
		case "SCDColor.deepskyblue": return SCDColor.deepskyblue
		case "SCDColor.whitesmoke": return SCDColor.whitesmoke
		case "SCDColor.grey": return SCDColor.grey
		case "SCDColor.chocolate": return SCDColor.chocolate
		case "SCDColor.honeydew": return SCDColor.honeydew
		case "SCDColor.seagreen": return SCDColor.seagreen
		case "SCDColor.antiquewhite": return SCDColor.antiquewhite
		case "SCDColor.aqua": return SCDColor.aqua
		case "SCDColor.aquamarine": return SCDColor.aquamarine
		case "SCDColor.gold": return SCDColor.gold
		case "SCDColor.hotpink": return SCDColor.hotpink
		case "SCDColor.mintcream": return SCDColor.mintcream
		case "SCDColor.lightsteelblue": return SCDColor.lightsteelblue
		case "SCDColor.tan": return SCDColor.tan
		case "SCDColor.snow": return SCDColor.snow
		case "SCDColor.dimgray": return SCDColor.dimgray
		case "SCDColor.silver": return SCDColor.silver
		case "SCDColor.springgreen": return SCDColor.springgreen
		case "SCDColor.lightcyan": return SCDColor.lightcyan
		case "SCDColor.lavender": return SCDColor.lavender
		case "SCDColor.orangered": return SCDColor.orangered
		case "SCDColor.mediumblue": return SCDColor.mediumblue
		case "SCDColor.lightyellow": return SCDColor.lightyellow
		case "SCDColor.midnightblue": return SCDColor.midnightblue
		case "SCDColor.powderblue": return SCDColor.powderblue
		case "SCDColor.floralwhite": return SCDColor.floralwhite
			
		default: return defaultColor
		
	}
}

public func EasySVGColorToRGB(_ svgColor: SCDColor) -> SCDGraphicsRGB
{
   var color: SCDGraphicsRGB
   
   switch(svgColor)
   {
   		case SCDColor.white: 	color = EasyColor.white; 	
   		case SCDColor.red: 		color = EasyColor.red; 		
   		case SCDColor.green:	color = EasyColor.green; 	
   		case SCDColor.black:	color = EasyColor.black; 	
   		case SCDColor.pink:		color = EasyColor.pink; 		
   		case SCDColor.orange:	color = EasyColor.orange; 	
   		case SCDColor.blue:		color = EasyColor.blue; 	
   		case SCDColor.gray:		color = EasyColor.gray; 	
   		case SCDColor.yellow:	color = EasyColor.yellow; 	
   		case SCDColor.purple:	color = EasyColor.purple; 	
   		
   		default: color = SCDGraphicsRGB.init(red: svgColor.red, green: svgColor.green, blue: svgColor.blue)
   }
   
   return color
}

public func EasyRGBColorToSVG(_ rgbColor: SCDGraphicsRGB) -> SCDColor
{
   var color2: SCDColor
   
   switch(rgbColor)
   {
   		case EasyColor.white: 	color2 = EasySVGColor.white;
   		case EasyColor.red:		color2 = EasySVGColor.red;
   		case EasyColor.green: 	color2 = EasySVGColor.green;
   		case EasyColor.black: 	color2 = EasySVGColor.black;
   		case EasyColor.pink: 	color2 = EasySVGColor.pink;
   		case EasyColor.orange: 	color2 = EasySVGColor.orange;
   		case EasyColor.blue: 	color2 = EasySVGColor.blue;
   		case EasyColor.gray:	color2 = EasySVGColor.gray;
   		case EasyColor.yellow: 	color2 = EasySVGColor.yellow;
   		case EasyColor.purple: 	color2 = EasySVGColor.purple;
   		
   		default: color2 = SCDColor.init(red: rgbColor.red, green: rgbColor.green, blue: rgbColor.blue)
   }
   
   return color2
}

// creates a SCDGraphicsFont
public func EasyFont(
    _ size: Int = 20,
  	_ name: String = "ArialMT",
  	_ color: SCDGraphicsRGB = EasyColor.black,
  	_ bold: Bool = false,
  	_ underline: Bool = false,
  	_ italic: Bool = false,
  	_ lineThrough: Bool = false 	
  ) -> SCDGraphicsFont
  {
  	let f: SCDGraphicsFont = SCDGraphicsFont()
    	 
    f.bold = bold
    f.color = color
    f.italic = italic
    f.lineThrough = lineThrough
    f.underline = underline
    f.size = size
    
    return f
  }


// creates a Loading Spinner
public func EasySpinner(_ show: Bool, _ text: String = "Loading...") {
	DispatchQueue.main.async {
    #if os(iOS)
        guard let rootView = SCDApplication.rootViewController?.view else { return }

        // Look for an existing spinner
        let tag = 999 // Arbitrary unique identifier for the spinner view
        if let existingSpinner = rootView.viewWithTag(tag) as? UIActivityIndicatorView {
            if !show {
                // Stop and remove existing spinner
                existingSpinner.stopAnimating()
                existingSpinner.removeFromSuperview()
            }
            // If a spinner is found and `show` is true, do nothing because it's already visible
            return
        }

        if show {
            // Initialize and configure the spinner
			var spinner: UIActivityIndicatorView
			if #available(iOS 13.0, *) {
         	spinner = UIActivityIndicatorView(style: .large)
			} else {
			 spinner = UIActivityIndicatorView(style: .whiteLarge)
			}
            spinner.color = .white 
            spinner.center = rootView.center
            spinner.tag = tag
            rootView.addSubview(spinner)
            spinner.startAnimating()

            // Optionally set a background to make it more visible
            spinner.backgroundColor = UIColor(white: 0, alpha: 0.6)         
            spinner.layer.cornerRadius = 10
        }
    
    #endif

    #if os(Android)
    // Android-specific spinner code
    
    easyProgress.setProgressStyle(style: ProgressDialog.STYLE_SPINNER)
    easyProgress.incrementProgressBy(diff: 1)
    easyProgress.setMessage(message: text)
    if show {
        easyProgress.show()  // Show spinner
    } else {
        easyProgress.dismiss()  // Hide spinner
    }
     
    #endif

	}
}


public func EasySpinner(_ seconds: Int, _ text: String = "Loading...", _ action: @escaping () -> Void = { }) {
	DispatchQueue.main.async {
		EasySpinner(true, text)
		DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds)) {
    		EasySpinner(false)
			action()
		}
	}
}

public func EasySwipeGesture(
		_ page: SCDWidgetsPage,
		_ direction: SCDSvgSwipeDirection = .right,
		_ action: @escaping () -> Void = { print("swiped") }
		)  {
		
		// Use short cut syntax to create recognizer and specify action
		let swipeGestureRecognizer = SCDSvgSwipeGestureRecognizer { handler in
    		
    		action()
    		
		}
		// Configure: capture swifts from left to right only
		swipeGestureRecognizer.direction = direction
		
		page.drawing!.gestureRecognizers.append(swipeGestureRecognizer)
	}
// add the gesture to the widget after the widget has been added to the page so that the recognizer will use the entire length of the widget instead of just the original page size
public func EasySwipeGesture(
		_ widget: SCDWidgetsWidget,
		_ direction: SCDSvgSwipeDirection = .right,
		_ action: @escaping () -> Void = { print("swiped") }
		)  {
		
		// Use short cut syntax to create recognizer and specify action
		let swipeGestureRecognizer = SCDSvgSwipeGestureRecognizer { handler in
    		
    		action()
    		
		}
		// Configure: capture swifts from left to right only
		swipeGestureRecognizer.direction = direction
		
		widget.drawing!.gestureRecognizers.append(swipeGestureRecognizer)
	}

private func Bubble(
    _ text: String, 
    color: SCDSvgRGBColor = SCDSvgRGBColor(red: 10, green: 132, blue: 255),
    fontcolor: SCDSvgRGBColor = SCDSvgColor.white
) -> BubbleInfo {
    // Create a rectangle
    let rectangle = SCDSvgRect()
    
    let components = text.components(separatedBy: .whitespacesAndNewlines)
    let words = components.filter { !$0.isEmpty }
    let totalCharacters = words.reduce(0) { $0 + $1.count } // Sum of all characters in words
    var width: Int
    var height: Int

    let characterWidth = 20 // Approximate width of each character
    let lineHeight = 30 // Height of each line
    let padding = 10 // Padding inside the bubble

    // Set a maximum number of characters per line to avoid overly wide bubbles
    let screenWidth = Int(screenInfo.screenSize.width)
    let maxCharactersPerLine = (screenWidth - 2 * padding) / characterWidth

    // Calculate width and height
    if totalCharacters > maxCharactersPerLine {
        let lines = (totalCharacters / maxCharactersPerLine) + (totalCharacters % maxCharactersPerLine > 0 ? 1 : 0)
        width = screenWidth - 20 // Use maximum available width
        height = lines * lineHeight + 2 * padding // Adjust height based on the number of lines
    } else {
        width = min(totalCharacters * characterWidth, screenWidth - 20) // Adjust width based on total characters
        height = lineHeight + 2 * padding // Single line height plus padding
    }

    // Set the corner radius
    rectangle.rx = 20 // Radius for x-axis corners
    rectangle.ry = 20 // Radius for y-axis corners

    let group = SCDSvgGroup()
    rectangle.fill = color
    group.children.append(rectangle)
    
    let lines = splitTextIntoLines(text)

    // Create and add each line of text to the group
    for (index, line) in lines.enumerated() {
        let svgText = SCDSvgText()
        svgText.text = line
        svgText.x = 10 // Adjust as needed
        svgText.y = SCDSvgUnit(integerLiteral: Int(25 + (index * 30))) // Adjust y based on line number
        svgText.fill = fontcolor
        svgText.fontSize = 20
        svgText.anchor = SCDSvgTextAnchor.start
        svgText.alignment = SCDSvgTextAlignment.left
        svgText.alignmentBaseline = SCDSvgTextAlignmentBaseline.auto
        svgText.fontName = "ArialMT"
        height = Int(25 + (index * 30)) + 10
        group.children.append(svgText)
    }

    // Translate width/height into SCDSvgUnits
    rectangle.width = SCDSvgUnit(integerLiteral: width)
    rectangle.height = SCDSvgUnit(integerLiteral: height)
    
    return BubbleInfo(group: group, size: SCDSize(width: Double(width), height: Double(height)))
}

private struct BubbleInfo {
    var group: SCDSvgGroup
    var size: SCDSize
}

private func splitTextIntoLines(_ text: String, _ fontsize: Int = 20) -> [String] {
    let components = text.components(separatedBy: .whitespacesAndNewlines)
    let words = components.filter { !$0.isEmpty }

    // Calculate adjustment factor based on fontsize changes, inversely proportional
    let baseFontSize = 20
    let adjustmentFactor = Double(baseFontSize) / Double(fontsize == 0 ? baseFontSize : fontsize)

    // Adjust maxWordsPerLine and maxLettersPerLine based on fontsize
    let maxLettersPerLine = Int(Double(Int(screenInfo.screenSize.width) / 10) * adjustmentFactor)

    var lines: [String] = []
    var currentLine = ""
    var currentLineLetterCount = 0

    for word in words {
        let wouldExceedLetterLimit = (currentLineLetterCount + word.count + 1) > maxLettersPerLine // +1 for space

        if wouldExceedLetterLimit {
            // Start a new line
            lines.append(currentLine.trimmingCharacters(in: .whitespaces))
            currentLine = word + " "
            currentLineLetterCount = word.count + 1 // Reset count, +1 for space
        } else {
            // Add word to the current line
            currentLine += word + " "
            currentLineLetterCount += word.count + 1 // Include current word and space
        }
    }

    // Add the final line if it's not empty
    if !currentLine.isEmpty {
        lines.append(currentLine.trimmingCharacters(in: .whitespaces))
    }

    return lines
}

private func createBubbleContainer(
    text: String, 
    color: SCDSvgRGBColor, 
    yPos: Int,
    fontcolor: SCDSvgRGBColor = SCDSvgColor.white
) -> SCDWidgetsContainer {
    let bubbleContainer = SCDWidgetsContainer()
    let bubbleDrawing = Bubble(text, color: color, fontcolor: fontcolor) 
    
    let label = SCDWidgetsLabel()
    label.drawing = bubbleDrawing.group // Set the SVG drawing
    
    // Use the bubble size directly from bubbleDrawing.size
    bubbleContainer.children.append(label)
    bubbleContainer.size = SCDGraphicsDimension(width: Int(bubbleDrawing.size.width), height: Int(bubbleDrawing.size.height)) // Use the actual size of the bubble
    bubbleContainer.location = SCDGraphicsPoint(x: 0, y: yPos)
    
    return bubbleContainer 
}

private func createCardContainer(
    path: String, 
    text: String, 
    description: String, 
    color: SCDSvgRGBColor, 
    yPos: Int
) -> SCDWidgetsContainer {
    let bubbleContainer = SCDWidgetsContainer()
    let bubbleDrawing = Rectangle(path: path, text: text, description: description) 
    
    let label = SCDWidgetsLabel()
    label.drawing = bubbleDrawing.group // Set the SVG drawing
    
    // Use the bubble size directly from bubbleDrawing.size
    bubbleContainer.children.append(label)
    bubbleContainer.size = SCDGraphicsDimension(width: Int(bubbleDrawing.size.width), height: Int(bubbleDrawing.size.height)) // Use the actual size of the bubble
    bubbleContainer.location = SCDGraphicsPoint(x: 0, y: yPos)
    bubbleContainer.paddingLeft = 10
    
    return bubbleContainer 
}

// Returns a SCDWidgetsContainer with the bubbles
public func EasySCDBubbles(
    _ bubbles: [EasySCDLayoutBubble], 
    width: Int = Int(screenInfo.screenSize.width),
    location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: 0) 
) -> SCDWidgetsContainer {
    let customElement = SCDWidgetsContainer()
    customElement.location = location

    var yOffset = 0
    for bubble in bubbles {
        // Create the name label
        let nameLabel = EasySCDTextLabel(
            bubble.name, 
            fontsize: 17,
            font: "ArialMT", 
            fontcolor: EasySCDColor(bubble.nameColor),
            paddingVertical: 0,
            paddingHorizontal: 10,
            x_location: 0,
            y_location: yOffset,
            bold: true
        )
        
        // Add the name label to the container
        customElement.children.append(nameLabel)
        yOffset += 30 // Adjust offset for the name label height
        
        let bubbleContainer = createBubbleContainer(
            text: bubble.text, 
            color: bubble.color, 
            yPos: yOffset,
            fontcolor: bubble.fontcolor
        )
        
        // Use the actual bubble height to adjust yOffset for the next container
        yOffset += Int(bubbleContainer.size.height) + 10 // Add some space between bubbles
        
        // Add the message bubble to the container
        customElement.children.append(bubbleContainer)
    }
    
    customElement.size = SCDGraphicsDimension(width: width, height: yOffset)

    return customElement
}

private func Rectangle(
    path: String,
    text: String,
    description: String,
    font: String = "ArialMT",
    fontColor: SCDGraphicsRGB = EasyColor.blue,
    width: Int = Int(screenInfo.screenSize.width - 10),
    height: Int = Int(screenInfo.screenSize.width - 10),
    cardColor: SCDGraphicsRGB = EasyColor.black
) -> BubbleInfo {
    let group = SCDSvgGroup()

    // Create image from path
    let image = SCDSvgImage()
    image.xhref = path
    image.x = 10
    image.y = 0
    image.width = SCDSvgUnit(integerLiteral: width)
    image.height = SCDSvgUnit(integerLiteral: height)
    group.children.append(image)

    let svgText = SCDSvgText()
    svgText.text = text
    svgText.x = SCDSvgUnit(integerLiteral: Int(width + 10) / 2)
    svgText.y = SCDSvgUnit(integerLiteral: 25) // Adjust y based on line number
    svgText.fill = SCDSvgColor.white
    svgText.fontSize = 25
    svgText.anchor = SCDSvgTextAnchor.middle
    svgText.alignment = SCDSvgTextAlignment.center
    svgText.alignmentBaseline = SCDSvgTextAlignmentBaseline.middle
    svgText.fontName = "ArialMT"
    group.children.append(svgText)

    let lines = splitTextIntoLines(description)

    // Create and add each line of text to the group
    for (index, line) in lines.enumerated() {
        let svgText = SCDSvgText()
        svgText.text = line
        svgText.x = SCDSvgUnit(integerLiteral: Int(width + 10) / 2)
        let divider = width - Int(30 * (lines.count - index))
        svgText.y = SCDSvgUnit(integerLiteral: divider) 
        svgText.fill = SCDSvgColor.white
        svgText.fontSize = 17
        svgText.anchor = SCDSvgTextAnchor.middle
        svgText.alignment = SCDSvgTextAlignment.center
        svgText.alignmentBaseline = SCDSvgTextAlignmentBaseline.middle
        svgText.fontName = "ArialMT"
        group.children.append(svgText)
    }

    return BubbleInfo(group: group, size: SCDSize(width: Double(width), height: Double(height)))
}

public struct EasySCDLayoutBubble {
public var name: String
    public var text: String
    public var color: SCDSvgRGBColor
    public var fontcolor: SCDSvgRGBColor
	public var nameColor: SCDSvgRGBColor = SCDSvgColor.white

    public init(
    name: String,
        text: String, 
        color: SCDSvgRGBColor = SCDSvgRGBColor(red: 10, green: 132, blue: 255),
        fontcolor: SCDSvgRGBColor = SCDSvgColor.white,
		nameColor: SCDSvgRGBColor = SCDSvgColor.white
    ) {
    	self.name = name
        self.text = text
        self.color = color
        self.fontcolor = fontcolor
		self.nameColor = nameColor
    }
}

public struct EasySCDLayoutBubbles {
    public var bubbles: [EasySCDLayoutBubble]

    public init(bubbles: [EasySCDLayoutBubble]) {
        self.bubbles = bubbles
    }
}


// returns a SCDWidgetsContainer with the Card
public func EasySCDCard	(
		path: String, 
		title: String, 
		description: String, 
		action: @escaping () -> Void = {  }
	) -> SCDWidgetsContainer {

    let customElement = SCDWidgetsContainer()
    
    
   
    let bubbleContainer = createCardContainer(
			path: path,
			text: title, 
			description: description,
			color: SCDSvgRGBColor(
				red: 255,
				green: 255,
				blue: 255
			), 
			yPos: 0
		)

        
    customElement.children.append(bubbleContainer)
    
	customElement.onClick { _ in action() }

	customElement.size = SCDGraphicsDimension(
			width: Int(screenInfo.screenSize.width), 
			height: Int(screenInfo.screenSize.width)
		)
	
	customElement.location = SCDGraphicsPoint(x: 0, y: 0)


   return customElement
}

#if os(iOS) 

extension SCDApplication {
	
	static var rootViewController : UIViewController? {
		
		get {
			return UIApplication.shared.delegate?.window??.rootViewController
		}
	}
}
#endif

// creates an alert 
public func EasyAlert(title:String, message:String,action: @escaping () -> Void = { }) {

	DispatchQueue.main.async {

    #if os(iOS)

      let alert = UIAlertController(
        title: title,
        message: message,
        preferredStyle: .alert)
      
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in action() }))

      SCDApplication.rootViewController?.present(alert, animated: true)

	
    #endif


    #if os(Android)

      let builder: AlertDialogBuilder = AlertDialogBuilder(context: Application.currentActivity!)
      builder.setTitle(title: title)
      builder.setMessage(message: message)

	//   let listener = DialogInterfaceOnClickListener.onClick {
	// 	(dialog, 0) in action()
	// 	}
	  builder.setPositiveButton(text: "OK", listener: nil)

	  let dialog: AlertDialog = builder.create()!

	  dialog.show()
	  
	#endif
      
	
	}

  }

private func EasySCDImageCache(_ key: String, _ value: String) -> SCDWidgetsImage {
    var imageWidget = SCDWidgetsImage()

    // Try to read the cached picture from storage
    if let picString = appStorage.read(key: key) {
        // Decode the base64 string after stripping the data URI prefix
        let base64String = picString.replacingOccurrences(of: "data:image/png;base64,", with: "")
        if let imageData = Data(base64Encoded: base64String) {
            // Set the image if existing cache data is valid
            imageWidget = EasySCDImageData(imageData)
        }
    }

    // Fetch the image from the provided URL if the cached image is not valid or doesn't exist
    if let profileImageURL = URL(string: value), let newImageData = try? Data(contentsOf: profileImageURL) {
        // Check if the new image data is different from what's already cached and it's not empty
        let newImageBase64String = newImageData.base64EncodedString()
        if appStorage.read(key: key) != newImageBase64String && !newImageData.isEmpty {
            // Save the new image as a base64 string to cache
            appStorage.write(key: key, value: newImageBase64String)
            // Create an image from the newly fetched data and update the widget
            imageWidget = EasySCDImageData(newImageData)
        }
    }

    return imageWidget
}



private func EasySCDImageCacheLocal(_ key: String, _ filePath: String) -> SCDWidgetsImage {
    var imageWidget = SCDWidgetsImage()

    // Check if the cached version of the file exists and is valid
    if let cachedString = appStorage.read(key: key) {
        let cachedImageData = Data(base64Encoded: cachedString.replacingOccurrences(of: "data:image/png;base64,", with: ""))
        if let imageData = cachedImageData {
            imageWidget = EasySCDImageData(imageData)
        }
    }

    // Check if the local file differs from the cached version or if the cached version is not valid
    if let newImageData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
        let newImageBase64String = newImageData.base64EncodedString()
        if appStorage.read(key: key) != newImageBase64String && !newImageData.isEmpty {
            // Save the new image as a base64 string to cache
            appStorage.write(key: key, value: newImageBase64String)
            // Update the image widget with the new image data
            imageWidget = EasySCDImageData(newImageData)
        }
    }

    return imageWidget
}



// creates SCDImagelabels from urls
public func EasySCDImageURL(
		_ path: String, 
		paddingVertical: Int = 0,
		paddingHorizontal: Int = 10,
		height: Int = Int(screenInfo.screenSize.width),
		width: Int = Int(screenInfo.screenSize.width),
		location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: 0),
		navigationAction: @escaping () -> Void = {  }) -> SCDWidgetsImage
{	
	let image = EasySCDImageCache(path, path)
			
	let size = SCDGraphicsDimension()
	size.height = height
	size.width = width        
	image.size = size  
	image.location = location
	image.name = path

	if paddingHorizontal > 0 {
		image.paddingLeft = paddingHorizontal
		image.size.width = width - paddingHorizontal
	}
	if paddingVertical > 0 {
		image.paddingTop = paddingVertical
	}

	
	image.onClick { _ in navigationAction() }

	return image
}

// 


// creates SCDImagelabels from local paths
public func EasySCDImage(
		_ path: String, 
		paddingVertical: Int = 0,
		paddingHorizontal: Int = 10,
		height: Int = Int(screenInfo.screenSize.width),
		width: Int = Int(screenInfo.screenSize.width),
		location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: 0),
		navigationAction: @escaping () -> Void = {
			
		
		}) -> SCDWidgetsImage
    {	
    	let image = EasySCDImageCacheLocal(path, path)
        
        let size = SCDGraphicsDimension()
        size.height = height
        size.width = width        
        image.size = size  
		image.location = location
		image.name = path

		if paddingHorizontal > 0 {
		image.paddingLeft = paddingHorizontal
		image.size.width = width - paddingHorizontal
		}
		if paddingVertical > 0 {
			image.paddingTop = paddingVertical
		}


        image.onClick { _ in navigationAction() }

        return image
    }

// creates SCDImagelabels from photo library
public func EasySCDImagePhotoLibrary(
		paddingVertical: Int = 0,
		paddingHorizontal: Int = 10,
		height: Int = Int(screenInfo.screenSize.width),
		width: Int = Int(screenInfo.screenSize.width),
		location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: 0),
		navigationAction: @escaping () -> Void = {

		}) -> SCDWidgetsImage
    {	
    	let image = SCDWidgetsImage()
        
        image.contentPriority = true

		EasySCDCamera(
			true,
			onImageLoaded: { data in
				image.content = data
			}
		)
		

        
        let size = SCDGraphicsDimension()
        size.height = height
        size.width = width        
        image.size = size  
		image.location = location
		image.name = "photoLibrary"

		if paddingHorizontal > 0 {
		image.paddingLeft = paddingHorizontal
		image.size.width = width - paddingHorizontal
		}
		if paddingVertical > 0 {
			image.paddingTop = paddingVertical
		}


        image.onClick { _ in navigationAction() }

        return image
    }
// creates SCDImagelabels from Data
public func EasySCDImageData(
		_ data: Data,
		paddingVertical: Int = 0,
		paddingHorizontal: Int = 10,
		height: Int = Int(screenInfo.screenSize.width),
		width: Int = Int(screenInfo.screenSize.width),
		location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: 0),
		navigationAction: @escaping () -> Void = {
			
		
		}) -> SCDWidgetsImage
    {	
    	let image = SCDWidgetsImage()
        
        image.contentPriority = true
        image.content = data
        
        let size = SCDGraphicsDimension()
        size.height = height
        size.width = width        
        image.size = size  
		image.location = location
		image.name = "photoLibrary"

		if paddingHorizontal > 0 {
		image.paddingLeft = paddingHorizontal
		image.size.width = width - paddingHorizontal
		}
		if paddingVertical > 0 {
			image.paddingTop = paddingVertical
		}


        image.onClick { _ in navigationAction() }

        return image
    }

// creates SCDButtons
public func EasySCDButton(
		_ text: String, 
		font: String = "ArialMT",
		color: SCDGraphicsRGB = EasyColor.blue,
		height: Int = 50,
		width: Int = Int(screenInfo.screenSize.width),
		paddingVertical: Int = 0,
		paddingHorizontal: Int = 0,
		location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: 0),
		action: @escaping () -> Void = {  }) -> SCDWidgetsButton
	{	
		let button = SCDWidgetsButton()
		
		button.text = text
		button.font!.fontFamily = font
		button.size = SCDGraphicsDimension(width: width, height: height)
		button.location = location
		button.font!.color = color
		button.onClick { _ in action() }

		if paddingHorizontal > 0 {
			button.paddingLeft = paddingHorizontal
			button.size.width = width - paddingHorizontal
			}
			if paddingVertical > 0 {
				button.paddingTop = paddingVertical
			}

		return button
	}

// create SCDTextboxes
public func EasySCDTextBox	(
		_ placeholder: String,
		secure: Bool = false,
		fontsize:Int = 20,
		font: String = "ArialMT", 
		fontcolor:SCDGraphicsRGB = EasyColor.black,
		width: Int = Int(screenInfo.screenSize.width) + 10,
		paddingVertical: Int = 10,
		paddingHorizontal: Int = 10,
		location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: 0)
	) -> SCDWidgetsTextbox
	
	{
		let tBox = SCDWidgetsTextbox()
		tBox.visible = true
		tBox.enable = true  
		tBox.placeholder = placeholder
		tBox.font!.fontFamily = font

    	tBox.keyboard = SCDWidgetsKeyboard.resize
		tBox.keyboardType = SCDWidgetsKeyboardType.alphabetic
    	tBox.secure = secure
    	tBox.text = ""
		tBox.horizontalAlignment = SCDLayoutHorizontalAlignment.left    	
    	tBox.baselineAlignment = SCDWidgetsBaselineAlignment.middle
    	tBox.verticalAlignment = SCDLayoutVerticalAlignment.middle
		tBox.size = SCDGraphicsDimension(width: width, height: Int(fontsize * 2) + paddingVertical)
		tBox.contentSize = SCDGraphicsDimension(width: width, height: Int(fontsize * 2) + paddingVertical)
		tBox.location = location
		tBox.font!.size = fontsize
		tBox.font!.color = fontcolor
		tBox.backgroundColor = EasyColor.gray
		tBox.cornerRadius = 5
		
		if paddingHorizontal > 0 {
			tBox.paddingLeft = paddingHorizontal
			tBox.size.width = width - paddingHorizontal
			}
			if paddingVertical > 0 {
				tBox.paddingTop = paddingVertical
			}

		return tBox
	}
public class EasySCDTextBoxForm {
	public var title: String
	public var textbox: SCDWidgetsTextbox
	
	public init	(
			title: String,
			textbox: SCDWidgetsTextbox
		) {

		self.title = title
		self.textbox = textbox
	}
}
// create TextForms
public func EasySCDTextForm(
	_ forms: [EasySCDTextBoxForm],
	fontsize:Int = 20,
		font: String = "ArialMT", 
		fontcolor:SCDGraphicsRGB = EasyColor.black,
		width: Int = Int(screenInfo.screenSize.width),
		location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: 0)
	) -> SCDWidgetsWidget
	{
		var elements = [SCDWidgetsWidget]()
		
		for form in forms
		{
			let container = SCDWidgetsContainer()
			let label = EasySCDTextLabel(
				form.title,
				fontsize: fontsize,
				font: font,
				fontcolor: fontcolor,
				paddingVertical: 0,
				paddingHorizontal: 10,
				x_location: 0,
				y_location: 0,
				bold: true,
				underline: true

			)

			let tBox = form.textbox
			tBox.location = SCDGraphicsPoint(x: 10, y: label.size.height - 10)
			tBox.size = SCDGraphicsDimension(width: width - 20, height: tBox.size.height)
			tBox.font!.size = fontsize
			tBox.font!.color = EasyColor.black


			container.location = location
			container.size = SCDGraphicsDimension(width: width, height: label.size.height + tBox.size.height)
			container.children.append(label)
			container.children.append(tBox)

			elements.append(container)
		}
		return EasySCDVStack(elements, location: location)
	}


// create SCDVideoViews
public func EasySCDWebView(
		_ url: String, 
		height: Int = Int(screenInfo.screenSize.width),
		width: Int = Int(screenInfo.screenSize.width),
		paddingVertical: Int = 0,
		paddingHorizontal: Int = 10,
		location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: 0)) -> SCDWidgetsWebView
  {
  	
  	let web = SCDWidgetsWebView()
    
    web.size = SCDGraphicsDimension(width: width, height: height)
    web.location = location
	web.backgroundColor = EasyColor.black

	if paddingHorizontal > 0 {
		web.paddingLeft = paddingHorizontal
		web.size.width = width - paddingHorizontal
		}
		if paddingVertical > 0 {
			web.paddingTop = paddingVertical
		}

	web.load(url)
    
    
    // Add event when page loaded
		web.onLoaded.append(SCDWidgetsLoadEventHandler{
			(ev:SCDWidgetsLoadEvent?) in 
			
		
			
			})
		
		
		// Add event when page failed to load
		web.onLoadFailed.append(SCDWidgetsLoadFailedEventHandler{
			(ev:SCDWidgetsLoadFailedEvent?) in 
			
			
			})
	
	web.onShouldLoad.append(SCDWidgetsShouldLoadEventHandler { event in
    // Your logic here, decide whether the web view should load the request
    
    return true  // Return true to allow loading, false to prevent it
})
	
	return web

}

// create SCDVideoViews
public func EasySCDWebView(
		url: String,
		page: SCDWidgetsPage, 
		height: Int = Int(screenInfo.screenSize.width),
		width: Int = Int(screenInfo.screenSize.width),
		paddingVertical: Int = 0,
		paddingHorizontal: Int = 10,
		location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: 0)) -> SCDWidgetsWebView
  {
  	
  	let web = SCDWidgetsWebView()
    
    web.size = SCDGraphicsDimension(width: width, height: height)
    web.location = location
	web.backgroundColor = EasyColor.black

	web.load(url)

	if paddingHorizontal > 0 {
		web.paddingLeft = paddingHorizontal
		web.size.width = width - paddingHorizontal
		}
		if paddingVertical > 0 {
			web.paddingTop = paddingVertical
		}

	page.onEnter.append(
      SCDWidgetsEnterEventHandler {
        (enterPageEvent: SCDWidgetsEnterEvent?) in

		

		 // Add event when page loaded
		web.onLoaded.append(SCDWidgetsLoadEventHandler{
			(ev:SCDWidgetsLoadEvent?) in 

			})
		
		
		// Add event when page failed to load
		web.onLoadFailed.append(SCDWidgetsLoadFailedEventHandler{
			(ev:SCDWidgetsLoadFailedEvent?) in 
				
			})
	
	web.onShouldLoad.append(SCDWidgetsShouldLoadEventHandler { event in
    // Your logic here, decide whether the web view should load the request
    
    return true  // Return true to allow loading, false to prevent it
})


	  }
	)

	page.onExit.append(
      SCDWidgetsExitEventHandler {
        (exitPageEvent: SCDWidgetsExitEvent?) in

		 web.onLoaded.removeAll()
        web.onLoadFailed.removeAll()
        web.onShouldLoad.removeAll()

	  }
	)



	
	return web

}

// change the text of an EasySCDTextLabel
extension SCDWidgetsContainer {
	
    public func setText(_ text: String) {
        if let tempContainer = self.children.first as? SCDWidgetsContainer,
           let label = tempContainer.children.first as? SCDWidgetsLabel {
            label.text = text
        }
    }
}

// create dynamic SCDTextLabels
public func EasySCDTextLabel(_ text: String, 
							fontsize:Int = 20,
							font: String = "ArialMT", 
							fontcolor:SCDGraphicsRGB = EasyColor.black,
							paddingVertical: Int = 0,
							paddingHorizontal: Int = 10,
							x_location: Int = 0,
							y_location: Int = 0,
							bold: Bool = false,
							underline: Bool = false,
							action: @escaping () -> Void = { }
							)-> SCDWidgetsContainer
    {	
		let paragraph = splitTextIntoLines(text, fontsize)
		var elements = [SCDWidgetsWidget]()
		var count = 1
		var yOffset = 0
		for line in paragraph
		{
			let label = SCDWidgetsLabel()
			
			label.visible = true
			label.enable = true       
	
			label.text = line
			label.font!.fontFamily = font
			label.font!.size = fontsize
			label.font!.color = fontcolor
			label.font!.bold = bold
			label.font!.underline = underline
			label.horizontalAlignment = SCDLayoutHorizontalAlignment.left    
    		label.baselineAlignment = SCDWidgetsBaselineAlignment.auto
    		label.verticalAlignment = SCDLayoutVerticalAlignment.middle
			label.layoutData = SCDLayoutAutoLayoutData()
			label.size = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: fontsize * 2 - (fontsize - 20))

			if paddingHorizontal > 0 {
			label.paddingLeft = paddingHorizontal
			label.size.width -= paddingHorizontal
			}
			if paddingVertical > 0 {
				label.paddingTop = paddingVertical
			}


			elements.append(label)
			count += 1
			yOffset += Int(label.size.height)
		}
        
		let stack = EasySCDVStack(elements, location: SCDGraphicsPoint(x: x_location, y: y_location), spacing: 0)
		stack.onClick { _ in action() }
		stack.size = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: Int(yOffset))
        return stack
    }


// creates a SCDCheckbox
public func EasySCDCheckbox(
		_ checked: Bool = false, 
		height: Int = 50,
		location: SCDGraphicsPoint = SCDGraphicsPoint(x: Int(screenInfo.screenSize.width / 2.5), y: 0)
		) -> SCDWidgetsCheckbox
  {
  	let checkbox = SCDWidgetsCheckbox()
  	checkbox.checked = checked
  	checkbox.enable = true
  	checkbox.visible = true
  	checkbox.size = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: height)
  	checkbox.location = location
  	checkbox.cornerRadius = 5

  	return checkbox
  }

// creates a SCDCheckboxElement (label + checkbox)
public func EasySCDCheckboxElement(
    _ text: String, 
    fontColor: SCDGraphicsRGB = EasyColor.black, 
    checked: Bool = false, 
    height: Int = 50, 
    action: @escaping () -> Void = { },
    onCheckedChanged: @escaping (Bool) -> Void = { _ in } // Add this callback
) -> SCDWidgetsContainer {
    let container = SCDWidgetsContainer()
    let label = EasySCDTextLabel(text, fontsize: 20, font: "ArialMT", fontcolor: fontColor, paddingVertical: 0, paddingHorizontal: 10, x_location: 0, y_location: 10)
    let checkbox = EasySCDCheckbox(checked, height: height)
    checkbox.location = SCDGraphicsPoint(x: Int(screenInfo.screenSize.width) - height - 20, y: 0)
    container.children.append(label)
    container.children.append(checkbox)
    container.size = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: height)
    container.location = SCDGraphicsPoint(x: 0, y: 0)

    // Setup click action for container
    container.onClick { _ in action() }
    
    // Add an onChange listener to the checkbox to handle checked changes
    checkbox.onClick { _ in
		onCheckedChanged(checkbox.checked)
    }

    return container
}


// creates a Checkbox form
public func EasySCDCheckboxForm(_ elements: [SCDWidgetsContainer]) -> SCDWidgetsContainer
{
	return EasySCDVStack(elements)
}

// creates a Spacer
public func EasySCDSpacer(_ height: Int = 20) -> SCDWidgetsWidget
{
	let sp = EasySCDTextLabel("", fontsize: height, font: "ArialMT", fontcolor: EasyColor.white, paddingVertical: height, paddingHorizontal: 0, x_location: 0, y_location: 0)
	sp.size = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: height)
	return sp
}


// opens photo library and returns image.content
public func EasySCDCamera(
		_ show: Bool = true,
		onImageLoaded: @escaping (Data) -> Void = { _ in }, // Add this callback 
		sourceType: SCDPlatformCameraSourceType = SCDPlatformCameraSourceType.photolibrary) -> Data
  {
  	let sys = SCDPlatformCamera()
	var imageContent: Data = Data()
  	
	if show {
    
    	sys.getPicture(
    		SCDPlatformCameraOptions.init(sourceType: SCDPlatformCameraSourceType.photolibrary), 
    		onSuccess: SCDPlatformCameraSuccessHandler.init(	{ 
    			data in 

					onImageLoaded(data)
    				imageContent = data
    		}), 
    		onError: SCDPlatformCameraErrorHandler.init(	{ 
    			_ in 
    				EasyAlert(title: "Upload Failed", message: "Failed to attach image.")
    		}))
    
	}
    
       return imageContent
  }


// dynamic vertical arrangement of widgets
public func EasySCDVStack(
		_ elements: [SCDWidgetsWidget], 
		location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: Int(screenInfo.statusBarsize.height) + 15),
		spacing: Int = 10
	) -> SCDWidgetsContainer {
	let container = SCDWidgetsContainer()
	container.location = location
	
	var yOffset = 0
	for element in elements {
		let tempContainer = SCDWidgetsContainer()
		tempContainer.location = SCDGraphicsPoint(x: Int(element.location.x), y: yOffset)
		tempContainer.size = SCDGraphicsDimension(width: Int(element.size.width), height: Int(element.size.height))
		yOffset += Int(element.size.height) + spacing
		tempContainer.children.append(element)
		container.children.append(tempContainer)
	}

	container.size = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: yOffset)
	
	return container
}
// dynamic vertical arrangement of widgets
public func EasySCDVStack(
		page: SCDWidgetsPage, 
		elements: [SCDWidgetsWidget], 
		location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: Int(screenInfo.statusBarsize.height) + 15),
		spacing: Int = 10
	)  {
	let container = SCDWidgetsContainer()
	container.location = location
	
	var yOffset = 0
	for element in elements {
		let tempContainer = SCDWidgetsContainer()
		tempContainer.location = SCDGraphicsPoint(x: Int(element.location.x), y: yOffset)
		tempContainer.size = SCDGraphicsDimension(width: Int(element.size.width), height: Int(element.size.height))
		yOffset += Int(element.size.height) + spacing
		tempContainer.children.append(element)
		container.children.append(tempContainer)
	}

	container.size = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: yOffset)
	
	page.children.append(container)
	page.useSafeArea = false
}

public func EasySCDHStack(
		page: SCDWidgetsPage, 
		elements: [SCDWidgetsWidget], 
		location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: Int(screenInfo.statusBarsize.height) + 15),
		spacing: Int = 10
)  {
	let container = SCDWidgetsContainer()
	container.location = location
	
	var xOffset = 0
	for element in elements {
		let tempContainer = SCDWidgetsContainer()
		tempContainer.location = SCDGraphicsPoint(x: xOffset, y: Int(element.location.y))
		tempContainer.size = SCDGraphicsDimension(width: Int(element.size.width), height: Int(element.size.height))
		xOffset += Int(element.size.width) + spacing
		tempContainer.children.append(element)
		container.children.append(tempContainer)
	}

	container.size = SCDGraphicsDimension(width: xOffset, height: Int(screenInfo.screenSize.height))
	
	page.children.append(container)
	page.useSafeArea = false
}
public func EasySCDHStack(
		_ elements: [SCDWidgetsWidget], 
		location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: Int(screenInfo.statusBarsize.height) + 15),
		spacing: Int = 10
	) -> SCDWidgetsContainer
{
	let container = SCDWidgetsContainer()
	container.location = location
	
	var xOffset = 0
	for element in elements {
		let tempContainer = SCDWidgetsContainer()
		tempContainer.location = SCDGraphicsPoint(x: xOffset, y: Int(element.location.y))
		tempContainer.size = SCDGraphicsDimension(width: Int(element.size.width), height: Int(element.size.height))
		xOffset += Int(element.size.width) + spacing
		tempContainer.children.append(element)
		container.children.append(tempContainer)
	}

	container.size = SCDGraphicsDimension(width: xOffset, height: Int(screenInfo.screenSize.height))
	
	return container
}

public func EasySCDPage(
		name: String,
		children: [SCDWidgetsWidget],
		useSafeArea: Bool = false,
		backgroundColor: SCDGraphicsRGB = EasyColor.white,
		backgroundImage: String = "",
		onEnter: @escaping () -> Void = { },
		onExit: @escaping () -> Void = { }
		) -> SCDWidgetsPage
	{
		let page = SCDWidgetsPage()
		page.name = name
		page.children = children
		page.useSafeArea = useSafeArea
		page.backgroundColor = backgroundColor
		page.location = SCDGraphicsPoint(x: 0, y: 0)
		page.size = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: Int(screenInfo.screenSize.height))
		page.onEnter.append(SCDWidgetsEnterEventHandler{ _ in onEnter() })
		page.onExit.append(SCDWidgetsExitEventHandler{ _ in onExit() })

		if !backgroundImage.isEmpty {
			page.backgroundImage = backgroundImage
		}

		return page
	}

public func EasySCDScrollbar() -> SCDSvgScrollGroup
{
	let scroll = SCDSvgScrollGroup()
    scroll.type = SCDSvgScrollType.vertical
    scroll.setScrollBarEnabled(true)
    scroll.height = Int(screenInfo.screenSize.height)
    scroll.width = Int(screenInfo.screenSize.width)
	scroll.visible = true

	let line = SCDSvgLine()
    line.x1 = SCDSvgUnit.init(integerLiteral: Int(screenInfo.screenSize.width - 10))	
    line.x2 = SCDSvgUnit.init(integerLiteral: Int(screenInfo.screenSize.width - 5))	
    line.y1 = SCDSvgUnit.init(integerLiteral: Int(screenInfo.screenSize.height - 10))	
    line.y2 = SCDSvgUnit.init(integerLiteral: Int(screenInfo.screenSize.height - 10))	
    line.visible = true

	scroll.children.append(line)

	return scroll
}

public func EasySCDScrollbar(
	_ page: SCDWidgetsPage, 
	_ widget: SCDWidgetsWidget,
	_ onScroll: @escaping () -> Void = { },
	onPageEnter: @escaping () -> Void = { },
	onPageExit: @escaping () -> Void = { }
	) -> SCDSvgScrollGroup
{	
	if let scb = page.getWidgetByName(widget.name)!.drawing!.findByAttribute("template-id", value: "content") as? SCDSvgScrollGroup
	{
		scb.onScroll.append((SCDSvgScrollHandler) { _ in onScroll() } )
	
    	page.onEnter.append(SCDWidgetsEnterEventHandler { (enterPageEvent: SCDWidgetsEnterEvent?) in onPageEnter() }) 
    	
    	page.onExit.append(SCDWidgetsExitEventHandler { (enterPageEvent: SCDWidgetsExitEvent?) in onPageExit() }) 
    	
    	return scb
	}
	else
	{
		return SCDSvgScrollGroup()
	}
}


public func EasySCDNavigationBar(
		backgroundColor: SCDGraphicsRGB = EasyColor.white,
		action: @escaping () -> Void = { },
		fontcolor: SCDGraphicsRGB = EasyColor.blue
		) -> SCDWidgetsNavigationBar
  {
  	let navbar = SCDWidgetsNavigationBar()
  	navbar.location = SCDGraphicsPoint(x: 0, y: 0)
	
  	navbar.backgroundColor = backgroundColor
  	navbar.name = "SCDNavigationBar"
  	
  	let label = EasySCDTextLabel(
    		 		"Back", 
    		 		fontsize: 20,
    		 		font: "ArialMT",
					fontcolor:fontcolor,
					paddingVertical:  0,
					paddingHorizontal: 0,
					x_location: Int(screenInfo.screenSize.width / 11),
					y_location: -3,
					action: {
						action()
					})
	label.size = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: 40)	
	navbar.size = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: 20)
	
  	navbar.children = [label]
  	
  	navbar.onClick { _ in
  		
  		action()

  	}
  	
  	let backArrow = navbar.drawing!.findByAttribute("template-id", value: "back-arrow-node") as! SCDSvgBox
		backArrow.fill = EasyRGBColorToSVG(fontcolor)		
		backArrow.x = SCDSvgUnit(integerLiteral: 10) 	
		backArrow.y = SCDSvgUnit(integerLiteral: 0) 
  	
  	return navbar
  }

public func EasySCDNavigationBar(
		page: SCDWidgetsPage,
		backgroundColor: SCDGraphicsRGB = EasyColor.white,
		action: @escaping () -> Void = { },
		fontcolor: SCDGraphicsRGB = EasyColor.blue
		) 
  {
  	let navbar = SCDWidgetsNavigationBar()
  	navbar.location = SCDGraphicsPoint(x: 0, y: 0)
	
  	navbar.backgroundColor = backgroundColor
  	navbar.name = "SCDNavigationBar"
  	
  	let label = EasySCDTextLabel(
    		 		"Back", 
    		 		fontsize: 20,
    		 		font: "ArialMT",
					fontcolor:fontcolor,
					paddingVertical:  0,
					paddingHorizontal: 0,
					x_location: Int(screenInfo.screenSize.width / 11),
					y_location: -3,
					action: {
						action()
					})
	label.size = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: 40)	
	navbar.size = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: 20)
	
  	navbar.children = [label]
  	
  	navbar.onClick { _ in
  		
  		action()

  	}
  	
  	let backArrow = navbar.drawing!.findByAttribute("template-id", value: "back-arrow-node") as! SCDSvgBox
		backArrow.fill = EasyRGBColorToSVG(fontcolor)		
		backArrow.x = SCDSvgUnit(integerLiteral: 10) 	
		backArrow.y = SCDSvgUnit(integerLiteral: 0) 
	
  	
  	page.children.append(navbar)

	EasySwipeGesture(page, .right, action) 
  }

public struct EasySCDToolbarItem
  {
  	 var image: String
  	 var action: () -> Void

	public init(image: String, action: @escaping () -> Void) {
		self.image = image
		self.action = action
	}

  }
  
public func EasySCDToolbar(_ items: [EasySCDToolbarItem], height: Int = 50, backgroundColor: SCDGraphicsRGB = EasyColor.gray) -> SCDWidgetsToolBar
    {
    	let toolBar = SCDWidgetsToolBar()
    	
    	//let tBut = SCDWidgetsTabButton()
    	//tBut.active = true
    	//tBut.text = "Home"
    	//tBut.name = "Home"
    	//tBut.size = SCDGraphicsDimension(width: 50, height: 50) 
    	//tBut.backgroundImage
    	
    	toolBar.layout = SCDLayoutAutoLayout() 	  
      	toolBar.backgroundColor = backgroundColor
        toolBar.size = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: height) 
        toolBar.location = SCDGraphicsPoint(x: 0, y: 0)
        
        let div = Int(screenInfo.screenSize.width / CGFloat(items.count))
        let mutli = (items.count) == 5 ? 20 : items.count == 4 ? 25 : items.count == 3 ? 40 : items.count == 2 ? 80 : Int(screenInfo.screenSize.width / 2) - 20       
        var count = 0
        
        for i in items
        {
        	let image = EasySCDImage(
    			i.image,
				paddingVertical: 0,
				paddingHorizontal: 0,
				height: 50,
				width: 50,
				location: SCDGraphicsPoint(x: mutli + (div * count), y: 0),
				navigationAction: {
					
      				i.action()
      				
				}
			)
			
			toolBar.children.append(image)

    	count+=1
    	
        }
        
        return toolBar
    }
	
public func EasySCDSeperator(_ y: Int = 20, _ strokeColor: SCDSvgColor = EasySVGColor.black, _ strokeWidth: Float = 1.0) -> SCDWidgetsWidget
  {
  	let line = SCDSvgLine()
    line.x1 = SCDSvgUnit(integerLiteral: 10)
    line.y1 = SCDSvgUnit(integerLiteral: y)
    line.x2 = SCDSvgUnit(integerLiteral: Int(screenInfo.screenSize.width) - 10)
    line.y2 = SCDSvgUnit(integerLiteral: y)

    // Setting the stroke color and width to make the line visible
    line.stroke = strokeColor // Black color
    line.strokeWidth = strokeWidth // Adjust stroke width as needed

    let group = SCDSvgGroup()
    group.children.append(line)
    
    let Label = SCDWidgetsLabel()
    Label.size = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: y)
    Label.location = SCDGraphicsPoint(x: 0, y: 0)
    Label.drawing = group // Set the SVG drawing
  	
  	return Label
  }

public struct EasySCDListElement {
  	 public var item: String
  	 public var fontsize: Int
  	 public var fontcolor: SCDGraphicsRGB
  	 public var action: () -> Void

	public init(item: String, fontsize: Int = 15, fontcolor: SCDGraphicsRGB = EasyColor.black, action: @escaping () -> Void = {}) {
		self.item = item
		self.fontsize = fontsize
		self.fontcolor = fontcolor
		self.action = action
	}
  }
  
public func EasySCDList(_ list: [EasySCDListElement]) -> SCDWidgetsContainer
  {
  	var textLabel: [SCDWidgetsWidget] = []
  	
  	 for i in list
  	 {
  	 	let label = EasySCDTextLabel(
  	 			i.item,
  	 			fontsize: i.fontsize,
				font: "ArialMT",
				fontcolor: i.fontcolor,
				paddingVertical: 0,
				paddingHorizontal: 0,
				x_location: 5,
				y_location: 0,
				bold: false,
				underline: false,
				action: {
					i.action()
				}
			
    	  )
  	 	textLabel.append(label)
    	let sec = EasySCDSeperator(10, SCDColor.black, 1.0)
		sec.size = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: 20)
    	textLabel.append(sec)
  	 	
  	 }

	 let stack = EasySCDVStack(textLabel, location: SCDGraphicsPoint(x: 0, y: 0), spacing: 0)
  	 
  	 
  	 return stack
  	 
}
  

