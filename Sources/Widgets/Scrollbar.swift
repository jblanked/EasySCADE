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