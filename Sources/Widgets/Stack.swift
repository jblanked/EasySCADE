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

public class EasyVStack {
    private var widgets: [SCDWidgetsWidget] = []
    private let spacing: Int
    
    // Assume widgets are passed directly to the initializer
    public init(spacing: Int = 10, widgets: [SCDWidgetsWidget]) {
        self.spacing = spacing
        self.widgets = widgets
    }
    
    
    // Simplified for direct widget array initialization
    public convenience init(spacing: Int = 10, @WidgetArrayBuilder _ builder: () -> [SCDWidgetsWidget]) {
        self.init(spacing: spacing, widgets: builder())
    }
    
    // Function to layout the widgets vertically
    public func layout(in parentWidget: SCDWidgetsContainer) {
        var yOffset = 0
        
	for element in self.widgets {
		let tempContainer = SCDWidgetsContainer()
		tempContainer.location = SCDGraphicsPoint(x: Int(element.location.x), y: yOffset)
		tempContainer.size = SCDGraphicsDimension(width: Int(element.size.width), height: Int(element.size.height))
		yOffset += Int(element.size.height) + spacing
		tempContainer.children.append(element)
		parentWidget.children.append(tempContainer)
	}

	parentWidget.size = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: yOffset)
    }
}

public class EasyHStack {
	private var widgets: [SCDWidgetsWidget] = []
	private let spacing: Int
	
	// Assume widgets are passed directly to the initializer
	public init(spacing: Int = 10, widgets: [SCDWidgetsWidget]) {
		self.spacing = spacing
		self.widgets = widgets
	}
	
	// Simplified for direct widget array initialization
	public convenience init(spacing: Int = 10, @WidgetArrayBuilder _ builder: () -> [SCDWidgetsWidget]) {
		self.init(spacing: spacing, widgets: builder())
	}
	
	// Function to layout the widgets horizontally
	public func layout(in parentWidget: SCDWidgetsContainer) {
		var xOffset = 0
		
	for element in self.widgets {
		let tempContainer = SCDWidgetsContainer()
		tempContainer.location = SCDGraphicsPoint(x: xOffset, y: Int(element.location.y))
		tempContainer.size = SCDGraphicsDimension(width: Int(element.size.width), height: Int(element.size.height))
		xOffset += Int(element.size.width) + spacing
		tempContainer.children.append(element)
		parentWidget.children.append(tempContainer)
	}

	parentWidget.size = SCDGraphicsDimension(width: xOffset, height: Int(screenInfo.screenSize.height))
	}
}

@resultBuilder
public struct WidgetArrayBuilder {
    public static func buildBlock(_ components: SCDWidgetsWidget...) -> [SCDWidgetsWidget] {
        components
    }
}

// dynamic vertical arrangement of widgets
public func EasySCDVStack(
		_ elements: [SCDWidgetsWidget], 
		location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: Int(screenInfo.statusBarsize.height) + 15),
		spacing: Int = 10
	) -> SCDWidgetsContainer {
	let container = SCDWidgetsContainer()
	container.location = location
	
	var yOffset = 0
	for element in elements {
		let tempContainer = SCDWidgetsContainer()
		tempContainer.location = SCDGraphicsPoint(x: Int(element.location.x), y: yOffset)
		tempContainer.size = SCDGraphicsDimension(width: Int(element.size.width), height: Int(element.size.height))
		yOffset += Int(element.size.height) + spacing
		tempContainer.children.append(element)
		container.children.append(tempContainer)
	}

	container.size = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: yOffset)
	
	return container
}
// dynamic vertical arrangement of widgets
public func EasySCDVStack(
		page: SCDWidgetsPage, 
		elements: [SCDWidgetsWidget], 
		location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: Int(screenInfo.statusBarsize.height) + 15),
		spacing: Int = 10
	)  {
	let container = SCDWidgetsContainer()
	container.location = location
	
	var yOffset = 0
	for element in elements {
		let tempContainer = SCDWidgetsContainer()
		tempContainer.location = SCDGraphicsPoint(x: Int(element.location.x), y: yOffset)
		tempContainer.size = SCDGraphicsDimension(width: Int(element.size.width), height: Int(element.size.height))
		yOffset += Int(element.size.height) + spacing
		tempContainer.children.append(element)
		container.children.append(tempContainer)
	}

	container.size = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: yOffset)
	
	page.children.append(container)
	page.useSafeArea = false
}

public func EasySCDHStack(
		page: SCDWidgetsPage, 
		elements: [SCDWidgetsWidget], 
		location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: Int(screenInfo.statusBarsize.height) + 15),
		spacing: Int = 10
)  {
	let container = SCDWidgetsContainer()
	container.location = location
	
	var xOffset = 0
	for element in elements {
		let tempContainer = SCDWidgetsContainer()
		tempContainer.location = SCDGraphicsPoint(x: xOffset, y: Int(element.location.y))
		tempContainer.size = SCDGraphicsDimension(width: Int(element.size.width), height: Int(element.size.height))
		xOffset += Int(element.size.width) + spacing
		tempContainer.children.append(element)
		container.children.append(tempContainer)
	}

	container.size = SCDGraphicsDimension(width: xOffset, height: Int(screenInfo.screenSize.height))
	
	page.children.append(container)
	page.useSafeArea = false
}
public func EasySCDHStack(
		_ elements: [SCDWidgetsWidget], 
		location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: Int(screenInfo.statusBarsize.height) + 15),
		spacing: Int = 10
	) -> SCDWidgetsContainer
{
	let container = SCDWidgetsContainer()
	container.location = location
	
	var xOffset = 0
	for element in elements {
		let tempContainer = SCDWidgetsContainer()
		tempContainer.location = SCDGraphicsPoint(x: xOffset, y: Int(element.location.y))
		tempContainer.size = SCDGraphicsDimension(width: Int(element.size.width), height: Int(element.size.height))
		xOffset += Int(element.size.width) + spacing
		tempContainer.children.append(element)
		container.children.append(tempContainer)
	}

	container.size = SCDGraphicsDimension(width: xOffset, height: Int(screenInfo.screenSize.height))
	
	return container
}