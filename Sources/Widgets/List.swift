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
