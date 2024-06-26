// Import necessary modules and conditionally import platform-specific ones
import ScadeKit
import EasySCADE
import Dispatch
import Foundation
import ScadeUI

#if os(iOS)
import UIKit 
import SwiftUI
import DeviceKit
#endif

#if os(Android)
import AndroidView
import Java
import Android
import AndroidApp
import AndroidContent
import AndroidOS
#endif


// create SCDTextboxes
public func EasySCDTextBox	(
		_ placeholder: String,
		secure: Bool = false,
		fontsize:Int = 20,
		font: String = "ArialMT", 
		fontcolor:SCDGraphicsRGB = EasyColor.black,
		width: Int = Int(screenInfo.screenSize.width) + 10,
		paddingVertical: Int = 10,
		paddingHorizontal: Int = 10,
		location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: 0)
	) -> SCDWidgetsTextbox
	
	{
		let tBox = SCDWidgetsTextbox()
		tBox.visible = true
		tBox.enable = true  
		tBox.placeholder = placeholder
		tBox.font!.fontFamily = font

    	tBox.keyboard = SCDWidgetsKeyboard.resize
		tBox.keyboardType = SCDWidgetsKeyboardType.alphabetic
    	tBox.secure = secure
    	tBox.text = ""
		tBox.horizontalAlignment = SCDLayoutHorizontalAlignment.left    	
    	tBox.baselineAlignment = SCDWidgetsBaselineAlignment.middle
    	tBox.verticalAlignment = SCDLayoutVerticalAlignment.middle
		tBox.size = SCDGraphicsDimension(width: width, height: Int(fontsize * 2) + paddingVertical)
		tBox.contentSize = SCDGraphicsDimension(width: width, height: Int(fontsize * 2) + paddingVertical)
		tBox.location = location
		tBox.font!.size = fontsize
		tBox.font!.color = fontcolor
		tBox.backgroundColor = EasyColor.gray
		tBox.cornerRadius = 5
		
		if paddingHorizontal > 0 {
			tBox.paddingLeft = paddingHorizontal
			tBox.size.width = width - paddingHorizontal
			}
			if paddingVertical > 0 {
				tBox.paddingTop = paddingVertical
			}

		return tBox
	}
public class EasySCDTextBoxForm {
	public var title: String
	public var textbox: SCDWidgetsTextbox
	
	public init	(
			title: String,
			textbox: SCDWidgetsTextbox
		) {

		self.title = title
		self.textbox = textbox
	}
}
// create TextForms
public func EasySCDTextForm(
	_ forms: [EasySCDTextBoxForm],
	fontsize:Int = 20,
		font: String = "ArialMT", 
		fontcolor:SCDGraphicsRGB = EasyColor.black,
		width: Int = Int(screenInfo.screenSize.width),
		location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: 0)
	) -> SCDWidgetsWidget
	{
		var elements = [SCDWidgetsWidget]()
		
		for form in forms
		{
			let container = SCDWidgetsContainer()
			let label = EasySCDTextLabel(
				form.title,
				fontsize: fontsize,
				font: font,
				fontcolor: fontcolor,
				paddingVertical: 0,
				paddingHorizontal: 10,
				x_location: 0,
				y_location: 0,
				bold: true,
				underline: true

			)

			let tBox = form.textbox
			tBox.location = SCDGraphicsPoint(x: 10, y: label.size.height - 10)
			tBox.size = SCDGraphicsDimension(width: width - 20, height: tBox.size.height)
			tBox.font!.size = fontsize
			tBox.font!.color = EasyColor.black


			container.location = location
			container.size = SCDGraphicsDimension(width: width, height: label.size.height + tBox.size.height)
			container.children.append(label)
			container.children.append(tBox)

			elements.append(container)
		}
		return EasySCDVStack(elements, location: location)
	}


#if os(iOS)

// Delegate Handler Class
private class TextViewDelegateHandler: NSObject, UITextViewDelegate {
    weak var easyTextbox: EasyTextbox?

    func textViewDidChange(_ textView: UITextView) {
        easyTextbox?.text = textView.text ?? ""  // Update the text property of EasyTextbox
		easyTextbox?.updatePlaceholderVisibility()
    }
    func textViewDidEndEditing(_ textView: UITextView) {         
        easyTextbox?.updatePlaceholderVisibility()    
    }  
    func textViewDidBeginEditing(_ textView: UITextView) {         
        easyTextbox?.placeholderLabel.isHidden = true     
    }
}

// EasyTextbox Class
public class EasyTextbox {
    public var textView: UITextView = UITextView()
    private let textViewDelegate = TextViewDelegateHandler()
    
    public var cornerRadius: CGFloat = 0.0
    private var oldText: String = ""
    public var text: String = ""
    public var alignment: NSTextAlignment {
		get {
			return textView.textAlignment ?? .left
		}
		set {
			textView.textAlignment = newValue
		}
	}
	
	public var placeholderLabel: UILabel = UILabel()
	public var fontColor: UIColor {
		get {
			return textView.textColor ?? .black
		}
		set {
			textView.textColor = newValue
		}
	
	}
	public var backgroundColor: UIColor {
		get {
			return textView.backgroundColor ?? .white
		}
		set {
			textView.backgroundColor = newValue
		}
	}
	
	public var placeholder: String {
		get {
			return placeholderLabel.text ?? ""
		}
		set {
			placeholderLabel.text = newValue
			placeholderLabel.sizeToFit()
		}
	}
	public var fontSize: CGFloat {
		get {
			return textView.font?.pointSize ?? 20
		}
		set {
			textView.font = UIFont.systemFont(ofSize: newValue)
			placeholderLabel.font = .italicSystemFont(ofSize: newValue)
			placeholderLabel.sizeToFit()
		}
	}
	public var location: SCDGraphicsPoint {
		get {
			return SCDGraphicsPoint(x: Int(textView.frame.origin.x), y: Int(textView.frame.origin.y))
		}
		set {
			textView.frame.origin = CGPoint(x: newValue.x, y: newValue.y)
			placeholderLabel.frame.origin = CGPoint(x: 5, y: (self.textView.font?.pointSize)! / 2)
		}
	}
	public var size: SCDGraphicsDimension {
		get {
			return SCDGraphicsDimension(width: Int(textView.frame.size.width), height: Int(textView.frame.size.height))
		}
		set {
			textView.frame.size = CGSize(width: CGFloat(newValue.width), height: CGFloat(newValue.height))
		}
	}

    public init(_ text: String = "Type Here") {
        self.textView = UITextView(frame: CGRect(x: Int(self.location.x), y: Int(self.location.y), width: Int(self.size.width), height: Int(self.size.height)))

        // Configure the appearance and properties of the textView
        self.textView.layer.masksToBounds = true
        self.textView.layer.cornerRadius = self.cornerRadius
        self.textView.layer.borderWidth = 1
        self.textView.layer.borderColor = UIColor.systemGray.cgColor
        self.textView.font = UIFont.systemFont(ofSize: self.fontSize)
        self.textView.textColor = self.fontColor
        self.textView.textAlignment = self.alignment
        self.textView.dataDetectorTypes = .all
        self.textView.layer.shadowOpacity = 0.5
        self.textView.isEditable = true
		self.textView.text = text
		self.textView.backgroundColor = self.backgroundColor

		self.placeholderLabel = UILabel()
        self.placeholderLabel.text = "Type your message here..."
        self.placeholderLabel.font = .italicSystemFont(ofSize: (self.textView.font?.pointSize)!)
        self.placeholderLabel.sizeToFit()
		self.textView.addSubview(self.placeholderLabel)
        self.placeholderLabel.frame.origin = CGPoint(x: 5, y: (self.textView.font?.pointSize)! / 2)
        self.placeholderLabel.textColor = .tertiaryLabel
		self.placeholderLabel.isHidden = self.text.isEmpty || self.text == "" ? false : true
        
        // Set the delegate to handle text changes
        self.textView.delegate = textViewDelegate
		self.textViewDelegate.easyTextbox = self
    }

    // Helper function to retrieve the current view controller
    private func getCurrentViewController() -> UIViewController? {
        return UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController
    }

	public func show() {
		if let currentVC = getCurrentViewController() {
			currentVC.view.addSubview(self.textView)
		}
	}

	public func hide() {
		self.textView.removeFromSuperview()
	}

	public func updatePlaceholderVisibility() {
        self.placeholderLabel.isHidden = !self.textView.text.isEmpty
    }
    
}
#endif

