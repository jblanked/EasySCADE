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

public func EasySCDPage(
		name: String,
		children: [SCDWidgetsWidget],
		useSafeArea: Bool = false,
		backgroundColor: SCDGraphicsRGB = EasyColor.white,
		backgroundImage: String = "",
		onEnter: @escaping () -> Void = { },
		onExit: @escaping () -> Void = { }
		) -> SCDWidgetsPage
	{
		let page = SCDWidgetsPage()
		page.name = name
		page.children = children
		page.useSafeArea = useSafeArea
		page.backgroundColor = backgroundColor
		page.location = SCDGraphicsPoint(x: 0, y: 0)
		page.size = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: Int(screenInfo.screenSize.height))
		page.onEnter.append(SCDWidgetsEnterEventHandler{ _ in onEnter() })
		page.onExit.append(SCDWidgetsExitEventHandler{ _ in onExit() })

		if !backgroundImage.isEmpty {
			page.backgroundImage = backgroundImage
		}

		return page
	}

	