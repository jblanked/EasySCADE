// Import necessary modules and conditionally import platform-specific ones
import ScadeKit
import Dispatch
import Foundation
import ScadeUI
import OpenCombine

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

// create dynamic SCDTextLabels
public func EasySCDTextLabel(_ text: String, 
							fontsize:Int = 20,
							font: String = "ArialMT", 
							fontcolor:SCDGraphicsRGB = EasyColor.black,
							paddingVertical: Int = 0,
							paddingHorizontal: Int = 10,
							x_location: Int = 0,
							y_location: Int = 0,
							bold: Bool = false,
							underline: Bool = false,
							action: @escaping () -> Void = { },
							alignment: SCDLayoutHorizontalAlignment = SCDLayoutHorizontalAlignment.left
							)-> SCDWidgetsContainer
    {	
		let paragraph = splitTextIntoLines(text, fontsize)
		var elements = [SCDWidgetsWidget]()
		var count = 1
		var yOffset = 0
		for line in paragraph
		{
			let label = SCDWidgetsLabel()
			
			label.visible = true
			label.enable = true       
	
			label.text = line
			label.font!.fontFamily = font
			label.font!.size = fontsize
			label.font!.color = fontcolor
			label.font!.bold = bold
			label.font!.underline = underline
			label.horizontalAlignment = alignment   
    		label.baselineAlignment = SCDWidgetsBaselineAlignment.auto
    		label.verticalAlignment = SCDLayoutVerticalAlignment.middle
			label.layoutData = SCDLayoutAutoLayoutData()
			label.size = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: fontsize * 2 - (fontsize - 20))

			if paddingHorizontal > 0 {
			label.paddingLeft = paddingHorizontal
			label.size.width -= paddingHorizontal
			}
			if paddingVertical > 0 {
				label.paddingTop = paddingVertical
			}


			elements.append(label)
			count += 1
			yOffset += Int(label.size.height)
		}
        
		let stack = EasySCDVStack(elements, location: SCDGraphicsPoint(x: x_location, y: y_location), spacing: 0)
		stack.onClick { _ in action() }
		stack.size = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: Int(yOffset))
        return stack
    }

@propertyWrapper
public struct EasyTextPublisher {
    private var textManager: EasySCDTextManager
    private static let didChangeNotification = Notification.Name("EasyTextPublisherDidChange")
    private var debounceWorkItem: DispatchWorkItem?

    public var wrappedValue: EasySCDTextManager {
        get { textManager }
        set {
            textManager = newValue
            debounceWorkItem?.cancel()
            let workItem = DispatchWorkItem { [weak textManager] in
                guard let textManager = textManager else { return }
                NotificationCenter.default.post(name: EasyTextPublisher.didChangeNotification, object: textManager)
            }
            debounceWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
        }
    }

    public init(wrappedValue: EasySCDTextManager) {
        self.textManager = wrappedValue
        NotificationCenter.default.addObserver(forName: EasyTextPublisher.didChangeNotification, object: textManager, queue: .main) { notification in
            guard let textManager = notification.object as? EasySCDTextManager else { return }
            textManager.updateLabel()
        }
    }
}



public class EasySCDTextManager {
    public var label: SCDWidgetsContainer
    private var fontSize: Int
    public var scdLabel: SCDWidgetsLabel {
        get {
            for item in self.label.children {
                guard let tempContainer = item as? SCDWidgetsContainer else {
                    continue
                }
                
                guard let tempLabel = tempContainer.children.first as? SCDWidgetsLabel else {
                    continue
                }
                
                return tempLabel
            }
            
            return SCDWidgetsLabel()
        }

        set {
            for item in self.label.children {
                guard let tempContainer = item as? SCDWidgetsContainer else {
                    continue
                }
                
                guard let tempLabel = tempContainer.children.first as? SCDWidgetsLabel else {
                    continue
                }
                
                tempLabel.text = newValue.text
                tempLabel.font!.size = newValue.font!.size
                tempLabel.font!.color = newValue.font!.color
                tempLabel.font!.fontFamily = newValue.font!.fontFamily
                tempLabel.font!.bold = newValue.font!.bold
                tempLabel.font!.underline = newValue.font!.underline
                tempLabel.horizontalAlignment = newValue.horizontalAlignment
                tempLabel.baselineAlignment = newValue.baselineAlignment
                tempLabel.verticalAlignment = newValue.verticalAlignment
                tempLabel.layoutData = newValue.layoutData
                tempLabel.size = newValue.size
                tempLabel.paddingLeft = newValue.paddingLeft
                tempLabel.paddingTop = newValue.paddingTop

                self.fontSize = newValue.font!.size

                break
            }
        }
    }
    
    public var text: String {
        get {
            return self.scdLabel.text ?? ""
        }
        
        set {  
            self.scdLabel.text = newValue
            self.scdLabel.font!.size = self.fontSize
        }
    }
    
    public init(_ text: String,
         fontsize: Int = 20,
         font: String = "ArialMT",
         fontcolor: SCDGraphicsRGB = EasyColor.black,
         paddingVertical: Int = 0,
         paddingHorizontal: Int = 10,
         x_location: Int = 0,
         y_location: Int = 0,
         bold: Bool = false,
         underline: Bool = false,
         action: @escaping () -> Void = { },
         alignment: SCDLayoutHorizontalAlignment = SCDLayoutHorizontalAlignment.left) {
        self.label = EasySCDTextLabel(
            text,
            fontsize: fontsize,
            font: font,
            fontcolor: fontcolor,
            paddingVertical: paddingVertical,
            paddingHorizontal: paddingHorizontal,
            x_location: x_location,
            y_location: y_location,
            bold: bold,
            underline: underline,
            action: action,
            alignment: alignment
        )
        self.fontSize = fontsize
    }

    public func updateLabel() {
        self.scdLabel.text = self.text
        self.scdLabel.font!.size = self.fontSize
    }
}






@propertyWrapper
public struct SCDLabelPublisher {
    private var labelState: SCDLabelState
    static let didChangeNotification = Notification.Name("SCDLabelStatePublisherDidChange")
    private var debounceWorkItem: DispatchWorkItem?
    
    public var wrappedValue: SCDLabelState {
        get { labelState }
        set {
            labelState = newValue
            debounceWorkItem?.cancel()
            let workItem = DispatchWorkItem { [weak labelState] in
                guard let labelState = labelState else { return }
                NotificationCenter.default.post(name: SCDLabelPublisher.didChangeNotification, object: labelState)
            }
            debounceWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
        }
    }

    public init(wrappedValue: SCDLabelState) {
        self.labelState = wrappedValue
        NotificationCenter.default.addObserver(forName: SCDLabelPublisher.didChangeNotification, object: nil, queue: .main) { notification in
            guard let labelState = notification.object as? SCDLabelState else { return }
            labelState.updateLabel()
        }
    }
}

public class SCDWidgetsLabelCombine: SCDLabelState {
    public var label: SCDWidgetsLabel
    private var cancellables: [OpenCombine.AnyCancellable] = []
    private var lastTask: EasyTask = EasyTask(id: 0, title: "")

    public var text: String {
        get { label.text ?? "" }
        set { label.text = newValue }
    }

    public init(
        _ text: String,
        fontSize: Int = 20,
        fontColor: SCDGraphicsRGB = EasyColor.black,
        font: String = "ArialMT",
        location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: 0),
        size: SCDGraphicsDimension = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: 50),
        alignment: SCDLayoutHorizontalAlignment = SCDLayoutHorizontalAlignment.left
    ) {
        label = SCDWidgetsLabel()
        label.location = location
        label.font!.fontFamily = font
        label.font!.size = fontSize
        label.font!.color = fontColor
        label.size = size
        label.horizontalAlignment = alignment
        label.baselineAlignment = SCDWidgetsBaselineAlignment.auto
        label.verticalAlignment = SCDLayoutVerticalAlignment.middle
        label.layoutData = SCDLayoutAutoLayoutData()

        self.subscribe()

        self.text = text
    }

    private func subscribe() {
        // Subscribe to changes in the task list to update label
        EasyCombine.shared.subscribeToChanges { [weak label] tasks in
            let text = tasks.map { $0.title }.joined()
            label?.text = text
        }
    }

    public func update(_ newText: String) {
        if self.lastTask.title != "" {
            EasyCombine.shared.removeTask(self.lastTask)
        }

        self.lastTask = EasyTask(id: EasyCombine.shared.tasks.count, title: newText)
        EasyCombine.shared.addTask(self.lastTask)
    }
}

public protocol SCDLabelState: AnyObject {
    var label: SCDWidgetsLabel { get }
    var text: String { get set }
    func updateLabel()
}

public extension SCDLabelState {
    func updateLabel() {
        self.label.text = self.text
    }
}

