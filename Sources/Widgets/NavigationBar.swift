// Import necessary modules and conditionally import platform-specific ones
import ScadeKit
import Dispatch
import Foundation
import ScadeUI

#if os(iOS)
import UIKit 
import SwiftUI
import AudioToolbox
#endif

#if os(Android)
import AndroidView
import Java
import Android
import AndroidApp
import AndroidContent
import AndroidOS
#endif

public func EasyVibrate() {
	#if os(iOS)
	AudioServicesPlaySystemSound(1519) // Actuate "Peek" feedback (weak boom)
	//AudioServicesPlaySystemSound(1520) // Actuate "Pop" feedback (strong boom)
	//AudioServicesPlaySystemSound(1521) // Actuate "Nope" feedback (series of three weak booms)
	#endif
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
  		EasyVibrate()
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
  		EasyVibrate()
  		action()

  	}
  	
  	let backArrow = navbar.drawing!.findByAttribute("template-id", value: "back-arrow-node") as! SCDSvgBox
		backArrow.fill = EasyRGBColorToSVG(fontcolor)		
		backArrow.x = SCDSvgUnit(integerLiteral: 10) 	
		backArrow.y = SCDSvgUnit(integerLiteral: 0) 
	
  	
  	page.children.append(navbar)

	EasySwipeGesture(page, .right, action) 
  }