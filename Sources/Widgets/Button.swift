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
		button.onClick { 
				_ in 
				EasyVibrate()
				action() 
			}

		if paddingHorizontal > 0 {
			button.paddingLeft = paddingHorizontal
			button.size.width = width - paddingHorizontal
			}
			if paddingVertical > 0 {
				button.paddingTop = paddingVertical
			}

		return button
	}
