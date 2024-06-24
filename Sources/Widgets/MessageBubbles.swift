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
#endif

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
            fontcolor: EasySCDSvgRGBColorToRGB(bubble.nameColor),
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

func splitTextIntoLines(_ text: String, _ fontSize: Int = 20) -> [String] {
    // Replace double spaces with a newline character to handle them as explicit line breaks
    let formattedText = text.replacingOccurrences(of: "  ", with: "\n")
    let components = formattedText.components(separatedBy: .newlines)
    
    // Calculate maximum letters per line based on font size and screen width
    let averageCharacterWidth = fontSize == 0 ? 10 : (10 / (20 / fontSize))
    let maxLettersPerLine = Int(screenInfo.screenSize.width / CGFloat(averageCharacterWidth))

    var lines: [String] = []
    
    for (index, component) in components.enumerated() {
        if index > 0 && !lines.isEmpty {
            // Add an extra line to create a double line break effect between segments
            lines.append("")
        }
        
        var line = ""
        let words = component.split(whereSeparator: { $0.isWhitespace }).map(String.init)
        
        for word in words {
            if line.count + word.count + 1 > maxLettersPerLine {
                // If the line exceeds the length, store it and start a new line
                lines.append(line.trimmingCharacters(in: .whitespaces))
                line = word 
            } else {
                // Otherwise, add the word to the current line
                line += (line.isEmpty ? "" : " ") + word
            }
        }

        // Add the last processed line if not empty
        if !line.isEmpty {
            lines.append(line.trimmingCharacters(in: .whitespaces))
        }
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