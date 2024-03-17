// Import necessary modules and conditionally import platform-specific ones
import ScadeKit
import Dispatch
import Foundation
import ScadeUI

#if !os(Android)
import UIKit 
import SwiftUI
#endif

#if os(Android)
import AndroidView
import Java
import Android
import AndroidApp
import AndroidContent
let easyProgress: ProgressDialog = ProgressDialog(context: Application.currentActivity!)
#endif


public class ScreenInfo: EObject {
    public var screenSize: CGSize
    public var statusBarVisible: Bool
    public var statusBarsize: CGSize
    
    public init(screenSize: CGSize, statusBarVisible: Bool, statusBarsize: CGSize) {
        self.screenSize = screenSize
        self.statusBarsize = statusBarsize
        self.statusBarVisible = statusBarVisible
    }
}

private func getWindowScreenSize() -> ScreenInfo {
    let size = SCDRuntime.system.getScreenSize()
    let statusBarVisible = SCDRuntime.system.statusBarVisible
    let statusBarsize = SCDRuntime.system.getScreenSafeArea()
    
    return ScreenInfo(
        screenSize: CGSize(width: size!.width, height: size!.height),
        statusBarVisible: statusBarVisible,
        statusBarsize: CGSize(width: statusBarsize!.bounds.width, height: statusBarsize!.bounds.height)
    )
}

public let screenInfo: ScreenInfo = getWindowScreenSize()

public func EasySpinner(show: Bool) {
    #if os(iOS)
    DispatchQueue.main.async {
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
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.color = .white 
            spinner.center = rootView.center
            spinner.tag = tag
            rootView.addSubview(spinner)
            spinner.startAnimating()

            // Optionally set a background to make it more visible
            spinner.backgroundColor = UIColor(white: 0, alpha: 0.6)         
            spinner.layer.cornerRadius = 10
        }
    }
    #endif

    #if os(Android)
    // Android-specific spinner code
    
    easyProgress.setProgressStyle(style: ProgressDialog.STYLE_SPINNER)
    easyProgress.incrementProgressBy(diff: 1)
    easyProgress.setMessage(message: "Loading..")
    if show {
        easyProgress.show()  // Show spinner
    } else {
        easyProgress.dismiss()  // Hide spinner
    }
     
    #endif
}

private func Bubble(text:String, color: SCDSvgRGBColor = SCDSvgRGBColor.init(red: 10, green: 132, blue: 255)) -> BubbleInfo
{
	 // Create a rectangle
    let rectangle = SCDSvgRect()
       
    
    let components = text.components(separatedBy: .whitespacesAndNewlines)
	let words = components.filter { !$0.isEmpty }
    let count = words.count
    let _ = ((Int(screenInfo.screenSize.width) / 10) * count)
    let totalCharacters = words.reduce(0) { $0 + $1.count } // Sum of all characters in words
    var width : Int
    var height: Int
    
    let _ = (Int(screenInfo.screenSize.width) / 10)
    
    // if more than 10 words 
    if count >= 10 
    {
    	width = Int(screenInfo.screenSize.width) - 10
    	height = Int((Int(screenInfo.screenSize.height) / 10) * Int(count/10)) + 15
    }

    else
    {
    	let div = Int((screenInfo.screenSize.width) / 22)
    	width = totalCharacters * div > Int(screenInfo.screenSize.width) - 10 ? Int(screenInfo.screenSize.width) - 10 : totalCharacters * div
    	height = (Int(screenInfo.screenSize.height) / 15)
    	
    }
    
    
    // Set the corner radius
	rectangle.rx = 20 // Radius for x-axis corners
	rectangle.ry = 20 // Radius for y-axis corners
	
	
	let group = SCDSvgGroup()
    group.children.append(rectangle)
	
    let lines = splitTextIntoLines(text: text)

    // Create and add each line of text to the group
    for (index, line) in lines.enumerated() {
        let svgText = SCDSvgText()
        svgText.text = line
        svgText.x = 10 // Adjust as needed
        svgText.y = SCDSvgUnit(integerLiteral: Int(25 + (index * 30))) // Adjust y based on line number
        svgText.fill = SCDSvgColor.white
        svgText.fontSize = 20
        svgText.anchor = SCDSvgTextAnchor.start
        svgText.alignment = SCDSvgTextAlignment.left
        svgText.alignmentBaseline = SCDSvgTextAlignmentBaseline.auto
        svgText.fontName = 	Arial
        height = Int(25 + (index * 30)) + 10
        group.children.append(svgText)
    }
    
     // translate width/height into SCDSvgUnits
    let widthEdit = SCDSvgUnit.init(integerLiteral: width)
    let heightEdit = SCDSvgUnit.init(integerLiteral: height)
    
    // set width, height, and color
    rectangle.width = widthEdit
    rectangle.height = heightEdit
    rectangle.fill = color
	
	
    return BubbleInfo.init(group: group, size: SCDSize(width: Double(width), height: Double(height)))
    
}

private struct BubbleInfo
{
	var group: SCDSvgGroup
	var size: SCDSize
}

private func splitTextIntoLines(text: String) -> [String] {

    let components = text.components(separatedBy: .whitespacesAndNewlines)
	let words = components.filter { !$0.isEmpty }
    let count = words.count
    
    let maxWordsPerLine = ((Int(screenInfo.screenSize.width) / 10) * count)
    let maxLettersPerLine = (Int(screenInfo.screenSize.width) / 10)
    

    var lines: [String] = []
    var currentLine = ""
    var currentLineWordCount = 0

    for word in words {
        // Check if adding the next word would exceed the line limits
        let wouldExceedWordLimit = (currentLineWordCount + 1) > maxWordsPerLine
        let wouldExceedLetterLimit = (currentLine.count + word.count + 1) > maxLettersPerLine // +1 for space

        if wouldExceedWordLimit || wouldExceedLetterLimit {
            // Start a new line
            lines.append(currentLine.trimmingCharacters(in: .whitespaces))
            currentLine = word + " "
            currentLineWordCount = 1
        } else {
            // Add word to the current line
            currentLine += word + " "
            currentLineWordCount += 1
        }
    }

    // Add the final line if it's not empty
    if !currentLine.isEmpty {
        lines.append(currentLine.trimmingCharacters(in: .whitespaces))
    }

    return lines
    }

private func createBubbleContainer(text: String, color: SCDSvgRGBColor, yPos: Int) -> SCDWidgetsContainer {
    let bubbleContainer = SCDWidgetsContainer()
    let bubbleDrawing = Bubble(text: text, color: color) // Assuming this returns your custom object with 'group' and 'size'
    
    let label = SCDWidgetsLabel()
    label.drawing = bubbleDrawing.group // Set the SVG drawing
    
    // Use the bubble size directly from bubbleDrawing.size
    bubbleContainer.children.append(label)
    bubbleContainer.size = SCDGraphicsDimension(width: Int(bubbleDrawing.size.width), height: Int(bubbleDrawing.size.height)) // Use the actual size of the bubble
    bubbleContainer.location = SCDGraphicsPoint(x: 0, y: yPos)
    
    return bubbleContainer 
}

public func EasyBubbles(info: [EasyLayoutBubble], width: Int = Int(screenInfo.screenSize.width),location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: 0) ) -> SCDWidgetsContainer {
    let customElement = SCDWidgetsContainer()
    
    customElement.location = location


    var yOffset = 0
    for text in info {
        let bubbleContainer = createBubbleContainer(text: text.text, color: text.color, yPos: yOffset)
        
        // Use the actual bubble height to adjust yOffset for the next container
        yOffset += Int(bubbleContainer.size.height) + 10 // Add some space between bubbles
        
        // add a SCDSvgText that says the user's name (appending it first will put the username on above the bubblw)
        
        customElement.children.append(bubbleContainer)
    }
    
    customElement.size = SCDGraphicsDimension(width: width, height: yOffset)

   return customElement
}

public struct EasyLayoutBubble
{
	var text: String
	var color: SCDSvgRGBColor = SCDSvgRGBColor.init(red: 10, green: 132, blue: 255)
}