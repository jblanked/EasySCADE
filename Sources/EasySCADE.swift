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

// stores the screen information
public let screenInfo: EasyScreenInfo = getWindowScreenSize()

// stores the app storage
public let appStorage: EasyAppStorage = EasyAppStorage()
