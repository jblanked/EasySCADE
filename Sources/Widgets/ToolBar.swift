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
					EasyVibrate()
      				i.action()
      				
				}
			)
			
			toolBar.children.append(image)

    	count+=1
    	
        }
        
        return toolBar
    }