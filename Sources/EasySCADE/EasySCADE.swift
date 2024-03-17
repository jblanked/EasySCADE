// Import necessary modules and conditionally import platform-specific ones
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

public class EasySCADE {

    public static var test: String = "Hello World"

    // Make ScreenInfo public and its properties as well
    public class ScreenInfo: EObject {
        public var screenSize: CGSize
        public var statusBarVisible: Bool
        public var statusBarsize: CGSize
        
        public init(screenSize: CGSize, statusBarVisible: Bool, statusBarsize: CGSize) {
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
    
    public static var screenInfo: ScreenInfo = getWindowScreenSize()
}
