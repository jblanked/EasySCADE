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
    let rectangle = SCDSvgRect()
    let group = SCDSvgGroup()
    rectangle.fill = color
    group.children.append(rectangle)

    let padding = 20 // Padding inside the bubble
    let lineHeight = 30 // Height of each line
    let fontSize = 20
    let fontName = "ArialMT"
    let maxWidth = Int(screenInfo.screenSize.width) - 40 // Max width with some margin

    // Function to estimate text width
    func estimateTextWidth(_ text: String) -> Int {
        let charCount = text.filter { !$0.isWhitespace }.count
        let wordCount = text.components(separatedBy: .whitespacesAndNewlines).count
        
        // Adjust character width based on text length and word count
        let averageCharWidth: Double
        if charCount <= 10 {
            averageCharWidth = 12.0 // Wider for very short texts
        } else if charCount <= 20 {
            averageCharWidth = 11.0 // Still wider for short texts
        } else {
            averageCharWidth = 10.0 // Normal width for longer texts
        }

        // Adjust space width based on word count
        let spaceWidth: Double = wordCount <= 2 ? 4.0 : 3.0

        let estimatedWidth = Double(charCount) * averageCharWidth + Double(wordCount - 1) * spaceWidth
        
        // Apply a small adjustment factor for fine-tuning
        let adjustmentFactor = charCount > 15 ? 1.02 : 0.98
        
        return Int(estimatedWidth * adjustmentFactor)
    }

    // Function to wrap text
    func wrapText(_ text: String) -> [String] {
        var lines: [String] = []
        var currentLine = ""
        
        for word in text.components(separatedBy: .whitespacesAndNewlines) {
            let testLine = currentLine.isEmpty ? word : "\(currentLine) \(word)"
            if estimateTextWidth(testLine) <= maxWidth - padding {
                currentLine = testLine
            } else {
                if !currentLine.isEmpty {
                    lines.append(currentLine)
                }
                currentLine = word
            }
        }
        if !currentLine.isEmpty {
            lines.append(currentLine)
        }
        return lines
    }

    let lines = wrapText(text)
    var maxLineWidth = 0

    for (index, line) in lines.enumerated() {
        let svgText = SCDSvgText()
        svgText.text = line
        svgText.x = SCDSvgUnit(integerLiteral: padding / 2)
        svgText.y = SCDSvgUnit(integerLiteral: lineHeight + (index * lineHeight))
        svgText.fill = fontcolor
        svgText.fontSize = fontSize
        svgText.anchor = SCDSvgTextAnchor.start
        svgText.alignment = SCDSvgTextAlignment.left
        svgText.alignmentBaseline = SCDSvgTextAlignmentBaseline.auto
        svgText.fontName = fontName
        group.children.append(svgText)

        let lineWidth = estimateTextWidth(line)
        maxLineWidth = max(maxLineWidth, lineWidth)
    }

    let width = min(maxLineWidth + padding, maxWidth)
    let height = lines.count * lineHeight + padding

    rectangle.width = SCDSvgUnit(integerLiteral: width)
    rectangle.height = SCDSvgUnit(integerLiteral: height)
    rectangle.rx = 20
    rectangle.ry = 20

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

    // Calculate adjustment factor based on fontsize changes, inversely proportional
    let baseFontSize = 20
    let adjustmentFactor = Double(baseFontSize) / Double(fontSize == 0 ? baseFontSize : fontSize)

    // Adjust maxWordsPerLine and maxLettersPerLine based on fontsize
    let maxLettersPerLine = Int(Double(Int(screenInfo.screenSize.width) / 10) * adjustmentFactor)
    
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
    bubbleContainer.location = SCDGraphicsPoint(x: 5, y: yPos)
    
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