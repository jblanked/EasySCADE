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
