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


// create SCDVideoViews
public func EasySCDWebView(
		_ url: String, 
		height: Int = Int(screenInfo.screenSize.width),
		width: Int = Int(screenInfo.screenSize.width),
		paddingVertical: Int = 0,
		paddingHorizontal: Int = 10,
		location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: 0)) -> SCDWidgetsWebView
  {
  	
  	let web = SCDWidgetsWebView()
    
    web.size = SCDGraphicsDimension(width: width, height: height)
    web.location = location
	web.backgroundColor = EasyColor.black

	if paddingHorizontal > 0 {
		web.paddingLeft = paddingHorizontal
		web.size.width = width - paddingHorizontal
		}
		if paddingVertical > 0 {
			web.paddingTop = paddingVertical
		}

	web.load(url)
    
    
    // Add event when page loaded
		web.onLoaded.append(SCDWidgetsLoadEventHandler{
			(ev:SCDWidgetsLoadEvent?) in 
			
		
			
			})
		
		
		// Add event when page failed to load
		web.onLoadFailed.append(SCDWidgetsLoadFailedEventHandler{
			(ev:SCDWidgetsLoadFailedEvent?) in 
			
			
			})
	
	web.onShouldLoad.append(SCDWidgetsShouldLoadEventHandler { event in
    // Your logic here, decide whether the web view should load the request
    
    return true  // Return true to allow loading, false to prevent it
})
	
	return web

}

// create SCDVideoViews
public func EasySCDWebView(
		url: String,
		page: SCDWidgetsPage, 
		height: Int = Int(screenInfo.screenSize.width),
		width: Int = Int(screenInfo.screenSize.width),
		paddingVertical: Int = 0,
		paddingHorizontal: Int = 10,
		location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: 0)) -> SCDWidgetsWebView
  {
  	
  	let web = SCDWidgetsWebView()
    
    web.size = SCDGraphicsDimension(width: width, height: height)
    web.location = location
	web.backgroundColor = EasyColor.black

	web.load(url)

	if paddingHorizontal > 0 {
		web.paddingLeft = paddingHorizontal
		web.size.width = width - paddingHorizontal
		}
		if paddingVertical > 0 {
			web.paddingTop = paddingVertical
		}

	page.onEnter.append(
      SCDWidgetsEnterEventHandler {
        (enterPageEvent: SCDWidgetsEnterEvent?) in

		

		 // Add event when page loaded
		web.onLoaded.append(SCDWidgetsLoadEventHandler{
			(ev:SCDWidgetsLoadEvent?) in 

			})
		
		
		// Add event when page failed to load
		web.onLoadFailed.append(SCDWidgetsLoadFailedEventHandler{
			(ev:SCDWidgetsLoadFailedEvent?) in 
				
			})
	
	web.onShouldLoad.append(SCDWidgetsShouldLoadEventHandler { event in
    // Your logic here, decide whether the web view should load the request
    
    return true  // Return true to allow loading, false to prevent it
})


	  }
	)

	page.onExit.append(
      SCDWidgetsExitEventHandler {
        (exitPageEvent: SCDWidgetsExitEvent?) in

		 web.onLoaded.removeAll()
        web.onLoadFailed.removeAll()
        web.onShouldLoad.removeAll()

	  }
	)



	
	return web

}
