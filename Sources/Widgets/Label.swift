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