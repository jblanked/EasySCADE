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


// creates a SCDCheckbox
public func EasySCDCheckbox(
		_ checked: Bool = false, 
		height: Int = 50,
		location: SCDGraphicsPoint = SCDGraphicsPoint(x: Int(screenInfo.screenSize.width / 2.5), y: 0)
		) -> SCDWidgetsCheckbox
  {
  	let checkbox = SCDWidgetsCheckbox()
  	checkbox.checked = checked
  	checkbox.enable = true
  	checkbox.visible = true
  	checkbox.size = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: height)
  	checkbox.location = location
  	checkbox.cornerRadius = 5

  	return checkbox
  }

// creates a SCDCheckboxElement (label + checkbox)
public func EasySCDCheckboxElement(
    _ text: String, 
    fontColor: SCDGraphicsRGB = EasyColor.black, 
    checked: Bool = false, 
    height: Int = 50, 
    action: @escaping () -> Void = { },
    onCheckedChanged: @escaping (Bool) -> Void = { _ in } // Add this callback
) -> SCDWidgetsContainer {
    let container = SCDWidgetsContainer()
    let label = EasySCDTextLabel(text, fontsize: 20, font: "ArialMT", fontcolor: fontColor, paddingVertical: 0, paddingHorizontal: 10, x_location: 0, y_location: 10)
    let checkbox = EasySCDCheckbox(checked, height: height)
    checkbox.location = SCDGraphicsPoint(x: Int(screenInfo.screenSize.width) - height - 20, y: 0)
    container.children.append(label)
    container.children.append(checkbox)
    container.size = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: height)
    container.location = SCDGraphicsPoint(x: 0, y: 0)

    // Setup click action for container
    container.onClick { _ in action() }
    
    // Add an onChange listener to the checkbox to handle checked changes
    checkbox.onClick { _ in
		onCheckedChanged(checkbox.checked)
    }

    return container
}


// creates a Checkbox form
public func EasySCDCheckboxForm(_ elements: [SCDWidgetsContainer]) -> SCDWidgetsContainer
{
	return EasySCDVStack(elements)
}