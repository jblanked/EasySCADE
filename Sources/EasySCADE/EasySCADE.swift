// The Swift Programming Language
// https://docs.swift.org/swift-book
import ScadeKit
import Dispatch
import Foundation
import ScadeUI

#if os(iOS)
import UIKit 
#endif

#if os(Android)
import AndroidView
import Java
#endif

// MARK: - EasySCADE

public class EasySCADE {

    class ScreenInfo: EObject {
	
	var screenSize: CGSize
	var statusBarVisible: Bool
	var statusBarsize: CGSize
	
	init(screenSize: CGSize, statusBarVisible: Bool, statusBarsize: CGSize)
	{
		self.screenSize = screenSize
		self.statusBarsize = statusBarsize
		self.statusBarVisible = statusBarVisible
	}
}

    public static func getWindowScreenSize() -> ScreenInfo {
    
    let sizee = SCDRuntime.system.getScreenSize()
    let statusBarVisible = SCDRuntime.system.statusBarVisible
   
    let statusBarsize = SCDRuntime.system.getScreenSafeArea()
    
    let screenInfo = ScreenInfo(
    	screenSize: CGSize(width: sizee!.width, height: sizee!.height),
    	statusBarVisible: statusBarVisible,
    	statusBarsize: CGSize(width: statusBarsize!.bounds.width, height: statusBarsize!.bounds.height)  
    	) 

    
    return screenInfo 
}
    
    public static var screenInfo: ScreenInfo = self.getWindowScreenSize() 
   
    
}