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
		placeholderLabel?.isHidden = !textView.text.isEmpty
    }
    func textViewDidEndEditing(_ textView: UITextView) {         
        placeholderLabel?.isHidden = !textView.text.isEmpty     
    }  
    func textViewDidBeginEditing(_ textView: UITextView) {         
        placeholderLabel?.isHidden = true     
    }
}

// EasyTextbox Class
public class EasyTextbox {
    public let textView: UITextView
    private let textViewDelegate = TextViewDelegateHandler()
    
    public var cornerRadius: CGFloat = 0.0
    private var oldText: String = ""
    public var text: String = ""
    public var alignment: NSTextAlignment = .left
	private var placeholderLabel: UILabel

    public init(
        _ placeholder: String = "Type Here",
        fontSize: CGFloat = 20,
        location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: 0),
        size: SCDGraphicsDimension = SCDGraphicsDimension(width: Int(UIScreen.main.bounds.width), height: 50)
    ) {
        textView = UITextView(frame: CGRect(x: Int(location.x), y: Int(location.y), width: Int(size.width), height: Int(size.height)))

        // Configure the appearance and properties of the textView
        textView.layer.masksToBounds = true
        textView.layer.cornerRadius = self.cornerRadius
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray.cgColor
        textView.font = UIFont.systemFont(ofSize: fontSize)
        textView.textColor = UIColor.black
        textView.textAlignment = self.alignment
        textView.dataDetectorTypes = .all
        textView.layer.shadowOpacity = 0.5
        textView.isEditable = true

		laceholderLabel = UILabel()
        placeholderLabel.text = "Type your message here..."
        placeholderLabel.font = .italicSystemFont(ofSize: (textView.font?.pointSize)!)
        placeholderLabel.sizeToFit()
		textView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (textView.font?.pointSize)! / 2)
        placeholderLabel.textColor = .tertiaryLabel
		placeholderLabel.isHidden = self.text.isEmpty

        self.text = textView.text

        // Set the delegate to handle text changes
        textView.delegate = textViewDelegate
        textViewDelegate.easyTextbox = self

        // Automatically add the textView to the current view controller's view
        if let currentVC = getCurrentViewController() {
            currentVC.view.addSubview(textView)
        }
    }

    // Helper function to retrieve the current view controller
    private func getCurrentViewController() -> UIViewController? {
        return UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController
    }

	public func remove() {
		self.textView.removeFromSuperview()
	}
    
}
#endif

