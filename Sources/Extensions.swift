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

extension SCDLatticePageAdapter {

    // add widgets to the current page
	public func append(_ widget: SCDWidgetsWidget) {
		self.page?.children.append(widget)
	}
	
    // get the screen size
	public var screenSize: CGSize {
		return CGSize(width: screenInfo.screenSize.width, height: screenInfo.screenSize.height)
	}

    // A method to lay out EasyVStack on the current page
    public func vStack(@WidgetArrayBuilder _ builder: () -> [SCDWidgetsWidget], _ spacing: Int = 10) {
        let st = EasyVStack.init(spacing: spacing, widgets: builder())
        st.layout(in: self.page!)
    }    

	// A method to lay out EasyHStack on the current page
	public func hStack(@WidgetArrayBuilder _ builder: () -> [SCDWidgetsWidget], _ spacing: Int = 10) {
		let st = EasyHStack.init(spacing: spacing, widgets: builder())
		st.layout(in: self.page!)
	}

    // method to navigate to a page
	public func navigateTo(_ page: String = "main.page") {
		DispatchQueue.main.async { self.navigation?.go(page: page) }
	}

    // add scroll bar to the current page
	public func scrollbar(
			_ onScroll: @escaping () -> Void = { },
			onPageEnter: @escaping () -> Void = { },
			onPageExit: @escaping () -> Void = { }
		) {
		 EasySCDScrollbar(
			self.page!,
			self.page!,
			onScroll,
			onPageEnter: onPageEnter,
			onPageExit: onPageExit
		)	
		
	}

    // add swipe gesture to the current page
	public func swipeGesture(
			_ action: @escaping () -> Void = {  },
			_ direction: SCDSvgSwipeDirection = .right
		)  {
			EasySwipeGesture(self.page!, direction, action)
		}

	// a method to set a page as a page
	public func setTemplate(_ template: SCDWidgetsPage) {
		self.page!.children = template.children
		self.page!.onEnter = template.onEnter
		self.page!.onExit = template.onExit
		self.page!.useSafeArea = template.useSafeArea
		self.page!.backgroundColor = template.backgroundColor
		self.page!.backgroundImage = template.backgroundImage
		self.page!.contentSize = template.contentSize
		self.page!.cornerRadius = template.cornerRadius
		self.page!.enable = template.enable
		self.page!.layout = template.layout
		self.page!.layoutData = template.layoutData
		self.page!.location = template.location
		self.page!.maxArea = template.maxArea
		self.page!.minArea = template.minArea
		self.page!.name = template.name
		self.page!.onClick = template.onClick
		self.page!.paddingBottom = template.paddingBottom
		self.page!.paddingTop = template.paddingTop
		self.page!.paddingLeft = template.paddingLeft
		self.page!.paddingRight = template.paddingRight
		self.page!.size = template.size
		self.page!.tag = template.tag
		self.page!.visible = template.visible
	}

}
// extension to SCDWidgetsWidget to add a swipe gesture
extension SCDWidgetsWidget {
	public func swipeGesture(
			_ action: @escaping () -> Void = {  },
			_ direction: SCDSvgSwipeDirection = .right
		)  {
			EasySwipeGesture(self, direction, action)
		}
}

extension SCDWidgetsContainer {
	// A method to lay out EasyVStack in a container
	public func vStack(@WidgetArrayBuilder _ builder: () -> [SCDWidgetsWidget], _ spacing: Int = 10) {
		let st = EasyVStack.init(spacing: spacing, widgets: builder())
		st.layout(in: self)
	}

	// A method to lay out EasyHStack in a container
	public func hStack(@WidgetArrayBuilder _ builder: () -> [SCDWidgetsWidget], _ spacing: Int = 10) {
		let st = EasyHStack.init(spacing: spacing, widgets: builder())
		st.layout(in: self)
	}
}


// extension to SCDGraphicsRGB to make it Equatable
extension SCDGraphicsRGB: Equatable {
    public static func ==(lhs: SCDGraphicsRGB, rhs: SCDGraphicsRGB) -> Bool {
        return lhs.red == rhs.red && lhs.green == rhs.green && lhs.blue == rhs.blue
    }
}

// extension to SCDSvgRGBColor to make it Equatable
extension SCDSvgRGBColor: Equatable {
    public static func ==(lhs: SCDSvgRGBColor, rhs: SCDSvgRGBColor) -> Bool {
        return lhs.red == rhs.red && lhs.green == rhs.green && lhs.blue == rhs.blue
    }
}

// change the text of an EasySCDTextLabel
extension SCDWidgetsContainer {
	
    public func setText(_ text: String) {
        if let tempContainer = self.children.first as? SCDWidgetsContainer,
           let label = tempContainer.children.first as? SCDWidgetsLabel {
            label.text = text
        }
    }
}

// redraw the SCDWidgetsContainer
extension SCDWidgetsContainer {
	
	public func refresh(_ newChildren: [SCDWidgetsWidget]) {
		DispatchQueue.main.async {
			self.children.removeAll()
			self.children = newChildren
		}
	}
}

#if os(iOS) 
// extension to SCDWidgetsContainer to add a SwiftUI view
extension SCDApplication {
	
	static var rootViewController : UIViewController? {
		
		get {
			return UIApplication.shared.delegate?.window??.rootViewController
		}
	}
}
#endif