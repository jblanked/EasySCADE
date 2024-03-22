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
let easyProgress: ProgressDialog = ProgressDialog(context: Application.currentActivity!)
#endif

// class to store user information
// public class Storage: EObject
// {
// 	var loggedIn: Bool
// 	var userInfo: ProfileData
	
// 	init(loggedIn: Bool, userInfo: ProfileData)
// 	{
// 		self.loggedIn = loggedIn
// 		self.userInfo = userInfo
// 	}
// }
// var appStorage:Storage = Storage()

// public func EasyStorageSave(_ storage: Storage = appStorage, _ relativePath: String = "appStorage")
// {
// 	SCDRuntime.saveDocument(relativePath: relativePath, document: appStorage)
// }

// public func EasyStorageLoad(_ relativePath: String = "appStorage")
// {
// 	appStorage = SCDRuntime.loadResource(relativePath: relativePath) as! Storage
// }

// class to store screen information
public class EasyScreenInfo: EObject {
    public var screenSize: CGSize
    public var statusBarVisible: Bool
    public var statusBarsize: CGSize
    
    public init(screenSize: CGSize, statusBarVisible: Bool, statusBarsize: CGSize) {
        self.screenSize = screenSize
        self.statusBarsize = statusBarsize
        self.statusBarVisible = statusBarVisible
    }
}

private func getWindowScreenSize() -> EasyScreenInfo {
    let size = SCDRuntime.system.getScreenSize()
    let statusBarVisible = SCDRuntime.system.statusBarVisible
    let statusBarsize = SCDRuntime.system.getScreenSafeArea()
    
    return EasyScreenInfo(
        screenSize: CGSize(width: size!.width, height: size!.height),
        statusBarVisible: statusBarVisible,
        statusBarsize: CGSize(width: statusBarsize!.bounds.width, height: statusBarsize!.bounds.height)
    )
}

// stores the screen information
public let screenInfo: EasyScreenInfo = getWindowScreenSize()

// colors
public struct EasyColor {
	public static let white = SCDGraphicsRGB(red: 248, green: 248, blue: 248)
	public static let blue = SCDGraphicsRGB(red: 10, green: 132, blue: 255) // iOS blue
	public static let black = SCDGraphicsRGB(red: 0, green: 0, blue: 0)
	public static let green = SCDGraphicsRGB(red: 48, green: 209, blue: 88) // iOS green
	public static let red = SCDGraphicsRGB(red: 215, green: 0, blue: 21) // iOS red
	public static let gray = SCDGraphicsRGB(red: 199, green: 199, blue: 204) // iOS gray
	public static let yellow = SCDGraphicsRGB(red: 255, green: 214, blue: 10) // iOS yellow
	public static let orange = SCDGraphicsRGB(red: 255, green: 159, blue: 10) // iOS orange
	public static let purple = SCDGraphicsRGB(red: 191, green: 90, blue: 242) // iOS purple
	public static let pink = SCDGraphicsRGB(red: 255, green: 55, blue: 95) // iOS pink
}

// creates a Loading Spinner
public func EasySpinner(_ show: Bool, _ text: String = "Loading...") {
	DispatchQueue.main.async {
    #if os(iOS)
        guard let rootView = SCDApplication.rootViewController?.view else { return }

        // Look for an existing spinner
        let tag = 999 // Arbitrary unique identifier for the spinner view
        if let existingSpinner = rootView.viewWithTag(tag) as? UIActivityIndicatorView {
            if !show {
                // Stop and remove existing spinner
                existingSpinner.stopAnimating()
                existingSpinner.removeFromSuperview()
            }
            // If a spinner is found and `show` is true, do nothing because it's already visible
            return
        }

        if show {
            // Initialize and configure the spinner
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.color = .white 
            spinner.center = rootView.center
            spinner.tag = tag
            rootView.addSubview(spinner)
            spinner.startAnimating()

            // Optionally set a background to make it more visible
            spinner.backgroundColor = UIColor(white: 0, alpha: 0.6)         
            spinner.layer.cornerRadius = 10
        }
    
    #endif

    #if os(Android)
    // Android-specific spinner code
    
    easyProgress.setProgressStyle(style: ProgressDialog.STYLE_SPINNER)
    easyProgress.incrementProgressBy(diff: 1)
    easyProgress.setMessage(message: text)
    if show {
        easyProgress.show()  // Show spinner
    } else {
        easyProgress.dismiss()  // Hide spinner
    }
     
    #endif

	}
}



private func Rectangle(
		path: String,
		text: String,
		description: String,
		font: String = "ArialMT",
		fontColor: SCDGraphicsRGB = EasyColor.blue,
		width: Int = Int(screenInfo.screenSize.width - 10),
		height: Int = Int(screenInfo.screenSize.width - 10),
		cardColor: SCDGraphicsRGB = EasyColor.black
	) -> BubbleInfo
	{


		let group = SCDSvgGroup()

		// create image from path
		let image = SCDSvgImage()
		image.xhref = path
		image.x = 10
		image.y = 0
		image.width = SCDSvgUnit.init(integerLiteral: width)
		image.height = SCDSvgUnit.init(integerLiteral: height)
		group.children.append(image)
	

        let svgText = SCDSvgText()
        svgText.text = text
        svgText.x = SCDSvgUnit(integerLiteral:Int(width + 10) / 2)
        svgText.y = SCDSvgUnit(integerLiteral: Int(25)) // Adjust y based on line number
        svgText.fill = SCDSvgColor.white
        svgText.fontSize = 25
        svgText.anchor = SCDSvgTextAnchor.middle
        svgText.alignment = SCDSvgTextAlignment.center
        svgText.alignmentBaseline = SCDSvgTextAlignmentBaseline.middle
        svgText.fontName = 	"ArialMT"
        
        group.children.append(svgText)
    

	let lines = splitTextIntoLines(description)

    // Create and add each line of text to the group
    for (index, line) in lines.enumerated() {
        let svgText = SCDSvgText()
        svgText.text = line
        svgText.x = SCDSvgUnit(integerLiteral:Int(width + 10) / 2)
		let divider = width - Int(30 * (lines.count - index))

        svgText.y = SCDSvgUnit	(
			integerLiteral: Int(divider)
		) 
        svgText.fill = SCDSvgColor.white
        svgText.fontSize = 17
        svgText.anchor = SCDSvgTextAnchor.middle
        svgText.alignment = SCDSvgTextAlignment.center
        svgText.alignmentBaseline = SCDSvgTextAlignmentBaseline.middle
        svgText.fontName = 	"ArialMT"
        group.children.append(svgText)
    }

	
	return BubbleInfo.init(group: group, size: SCDSize(width: Double(width), height: Double(height)))  

	}


private func Bubble(_ text:String, color: SCDSvgRGBColor = SCDSvgRGBColor.init(red: 10, green: 132, blue: 255)) -> BubbleInfo
{
	 // Create a rectangle
    let rectangle = SCDSvgRect()
       
    
    let components = text.components(separatedBy: .whitespacesAndNewlines)
	let words = components.filter { !$0.isEmpty }
    let count = words.count
    let _ = ((Int(screenInfo.screenSize.width) / 10) * count)
    let totalCharacters = words.reduce(0) { $0 + $1.count } // Sum of all characters in words
    var width : Int
    var height: Int
    
    let _ = (Int(screenInfo.screenSize.width) / 10)
    
    // if more than 10 words 
    if count >= 10 
    {
    	width = Int(screenInfo.screenSize.width) - 10
    	height = Int((Int(screenInfo.screenSize.height) / 10) * Int(count/10)) + 15
    }

    else
    {
    	let div = Int((screenInfo.screenSize.width) / 22)
    	width = totalCharacters * div > Int(screenInfo.screenSize.width) - 10 ? Int(screenInfo.screenSize.width) - 10 : totalCharacters * div
    	height = (Int(screenInfo.screenSize.height) / 15)
    	
    }
    
    
    // Set the corner radius
	rectangle.rx = 20 // Radius for x-axis corners
	rectangle.ry = 20 // Radius for y-axis corners
	
	
	let group = SCDSvgGroup()
    group.children.append(rectangle)
	
    let lines = splitTextIntoLines(text)

    // Create and add each line of text to the group
    for (index, line) in lines.enumerated() {
        let svgText = SCDSvgText()
        svgText.text = line
        svgText.x = 10 // Adjust as needed
        svgText.y = SCDSvgUnit(integerLiteral: Int(25 + (index * 30))) // Adjust y based on line number
        svgText.fill = SCDSvgColor.white
        svgText.fontSize = 20
        svgText.anchor = SCDSvgTextAnchor.start
        svgText.alignment = SCDSvgTextAlignment.left
        svgText.alignmentBaseline = SCDSvgTextAlignmentBaseline.auto
        svgText.fontName = 	"ArialMT"
        height = Int(25 + (index * 30)) + 10
        group.children.append(svgText)
    }
    
     // translate width/height into SCDSvgUnits
    let widthEdit = SCDSvgUnit.init(integerLiteral: width)
    let heightEdit = SCDSvgUnit.init(integerLiteral: height)
    
    // set width, height, and color
    rectangle.width = widthEdit
    rectangle.height = heightEdit
    rectangle.fill = color
	
	
    return BubbleInfo.init(group: group, size: SCDSize(width: Double(width), height: Double(height)))
    
}

private struct BubbleInfo
{
	var group: SCDSvgGroup
	var size: SCDSize
}

private func splitTextIntoLines(_ text: String) -> [String] {

    let components = text.components(separatedBy: .whitespacesAndNewlines)
	let words = components.filter { !$0.isEmpty }
    let count = words.count
    
    let maxWordsPerLine = ((Int(screenInfo.screenSize.width) / 10) * count)
    let maxLettersPerLine = (Int(screenInfo.screenSize.width) / 10)
    

    var lines: [String] = []
    var currentLine = ""
    var currentLineWordCount = 0

    for word in words {
        // Check if adding the next word would exceed the line limits
        let wouldExceedWordLimit = (currentLineWordCount + 1) > maxWordsPerLine
        let wouldExceedLetterLimit = (currentLine.count + word.count + 1) > maxLettersPerLine // +1 for space

        if wouldExceedWordLimit || wouldExceedLetterLimit {
            // Start a new line
            lines.append(currentLine.trimmingCharacters(in: .whitespaces))
            currentLine = word + " "
            currentLineWordCount = 1
        } else {
            // Add word to the current line
            currentLine += word + " "
            currentLineWordCount += 1
        }
    }

    // Add the final line if it's not empty
    if !currentLine.isEmpty {
        lines.append(currentLine.trimmingCharacters(in: .whitespaces))
    }

    return lines
    }

private func createBubbleContainer(text: String, color: SCDSvgRGBColor, yPos: Int) -> SCDWidgetsContainer {
    let bubbleContainer = SCDWidgetsContainer()
    let bubbleDrawing = Bubble(text, color: color) 
    
    let label = SCDWidgetsLabel()
    label.drawing = bubbleDrawing.group // Set the SVG drawing
    
    // Use the bubble size directly from bubbleDrawing.size
    bubbleContainer.children.append(label)
    bubbleContainer.size = SCDGraphicsDimension(width: Int(bubbleDrawing.size.width), height: Int(bubbleDrawing.size.height)) // Use the actual size of the bubble
    bubbleContainer.location = SCDGraphicsPoint(x: 0, y: yPos)
    
    return bubbleContainer 
}
private func createCardContainer(path: String, text: String, description: String, color: SCDSvgRGBColor, yPos: Int) -> SCDWidgetsContainer {
    let bubbleContainer = SCDWidgetsContainer()
    let bubbleDrawing = Rectangle(path: path, text: text, description: description) 
    
    let label = SCDWidgetsLabel()
    label.drawing = bubbleDrawing.group // Set the SVG drawing
    
    // Use the bubble size directly from bubbleDrawing.size
    bubbleContainer.children.append(label)
    bubbleContainer.size = SCDGraphicsDimension(width: Int(bubbleDrawing.size.width), height: Int(bubbleDrawing.size.height)) // Use the actual size of the bubble
    bubbleContainer.location = SCDGraphicsPoint(x: 0, y: yPos)
	bubbleContainer.paddingLeft = 10
    
    return bubbleContainer 
}
// returns a SCDWidgetsContainer with the bubbles
public func EasySCDBubbles(_ bubbles: [EasySCDLayoutBubble], width: Int = Int(screenInfo.screenSize.width),location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: 0) ) -> SCDWidgetsContainer {
    let customElement = SCDWidgetsContainer()
    
    customElement.location = location


    var yOffset = 0
    for text in bubbles {
        let bubbleContainer = createBubbleContainer(text: text.text, color: text.color, yPos: yOffset)
        
        // Use the actual bubble height to adjust yOffset for the next container
        yOffset += Int(bubbleContainer.size.height) + 10 // Add some space between bubbles
        
        // add a SCDSvgText that says the user's name (appending it first will put the username on above the bubblw)
        
        customElement.children.append(bubbleContainer)
    }
    
    customElement.size = SCDGraphicsDimension(width: width, height: yOffset)

   return customElement
}

// returns a SCDWidgetsContainer with the Card
public func EasySCDCard	(
		path: String, 
		title: String, 
		description: String, 
		action: @escaping () -> Void = {  }
	) -> SCDWidgetsContainer {

    let customElement = SCDWidgetsContainer()
    
    
   
    let bubbleContainer = createCardContainer(
			path: path,
			text: title, 
			description: description,
			color: SCDSvgRGBColor(
				red: 255,
				green: 255,
				blue: 255
			), 
			yPos: 0
		)

        
    customElement.children.append(bubbleContainer)
    
	customElement.onClick { _ in action() }

	customElement.size = SCDGraphicsDimension(
			width: Int(screenInfo.screenSize.width), 
			height: Int(screenInfo.screenSize.width)
		)
	
	customElement.location = SCDGraphicsPoint(x: 0, y: 0)


   return customElement
}

public struct EasySCDLayoutBubble {
    public var text: String
    public var color: SCDSvgRGBColor

    public init(text: String, color: SCDSvgRGBColor = SCDSvgRGBColor(red: 10, green: 132, blue: 255)) {
        self.text = text
        self.color = color
    }
}

public struct EasySCDLayoutBubbles {
	public var bubbles: [EasySCDLayoutBubble]

	public init(bubbles: [EasySCDLayoutBubble]) {
		self.bubbles = bubbles
	}
}


#if os(iOS) 

extension SCDApplication {
	
	static var rootViewController : UIViewController? {
		
		get {
			return UIApplication.shared.delegate?.window??.rootViewController
		}
	}
}
#endif

// creates an alert 
public func EasyAlert(title:String, message:String,action: @escaping () -> Void = { }) {

	DispatchQueue.main.async {

    #if !os(Android)

      let alert = UIAlertController(
        title: title,
        message: message,
        preferredStyle: .alert)
      
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in action() }))

      SCDApplication.rootViewController?.present(alert, animated: true)

	
    #endif


    #if os(Android)

      let builder: AlertDialogBuilder = AlertDialogBuilder(context: Application.currentActivity!)
      builder.setTitle(title: title)
      builder.setMessage(message: message)

	//   let listener = DialogInterfaceOnClickListener {
	// 	(dialog, which) in action()
	// 	}
	  builder.setPositiveButton(text: "OK", listener: nil)

	  let dialog: AlertDialog = builder.create()!

	  dialog.show()
	  
	#endif
      
	
	}

  }
  

// creates SCDImagelabels from urls
public func EasySCDImageURL(
		_ path: String, 
		paddingVertical: Int = 0,
		paddingHorizontal: Int = 10,
		height: Int = Int(screenInfo.screenSize.width),
		width: Int = Int(screenInfo.screenSize.width),
		location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: 0),
		navigationAction: @escaping () -> Void = {  }) -> SCDWidgetsImage
{	
	let image = SCDWidgetsImage()
			
	// Create URL
	let url = URL(string: path)!

	DispatchQueue.main.async {
		// Fetch Image Data
		if let data = try? Data(contentsOf: url) {
		
		DispatchQueue.main.async {
			// Create Image and Update Image Control
			image.contentPriority = true
			image.content = data
		}
		}
	}
			
	let size = SCDGraphicsDimension()
	size.height = height
	size.width = width        
	image.size = size  
	image.location = location
	image.name = path

	if paddingHorizontal > 0 {
		image.paddingLeft = paddingHorizontal
		image.size.width = width - paddingHorizontal
	}
	if paddingVertical > 0 {
		image.paddingTop = paddingVertical
	}

	
	image.onClick { _ in navigationAction() }

	return image
}

// creates SCDImagelabels from local paths
public func EasySCDImage(
		_ path: String, 
		paddingVertical: Int = 0,
		paddingHorizontal: Int = 10,
		height: Int = Int(screenInfo.screenSize.width),
		width: Int = Int(screenInfo.screenSize.width),
		location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: 0),
		navigationAction: @escaping () -> Void = {
			
		
		}) -> SCDWidgetsImage
    {	
    	let image = SCDWidgetsImage()
        
        image.url = path
        image.contentPriority = false
        
        let size = SCDGraphicsDimension()
        size.height = height
        size.width = width        
        image.size = size  
		image.location = location
		image.name = path

		if paddingHorizontal > 0 {
		image.paddingLeft = paddingHorizontal
		image.size.width = width - paddingHorizontal
		}
		if paddingVertical > 0 {
			image.paddingTop = paddingVertical
		}


        image.onClick { _ in navigationAction() }

        return image
    }

// creates SCDImagelabels from photo library
public func EasySCDImagePhotoLibrary(

		paddingVertical: Int = 0,
		paddingHorizontal: Int = 10,
		height: Int = Int(screenInfo.screenSize.width),
		width: Int = Int(screenInfo.screenSize.width),
		location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: 0),
		navigationAction: @escaping () -> Void = {
			
		
		}) -> SCDWidgetsImage
    {	
    	let image = SCDWidgetsImage()
        
        image.contentPriority = true

		EasySCDCamera(
			true,
			onImageLoaded: { data in
				image.content = data
			}
		)
		

        
        let size = SCDGraphicsDimension()
        size.height = height
        size.width = width        
        image.size = size  
		image.location = location
		image.name = "photoLibrary"

		if paddingHorizontal > 0 {
		image.paddingLeft = paddingHorizontal
		image.size.width = width - paddingHorizontal
		}
		if paddingVertical > 0 {
			image.paddingTop = paddingVertical
		}


        image.onClick { _ in navigationAction() }

        return image
    }
// creates SCDImagelabels from Data
public func EasySCDImageData(
		_ data: Data,
		paddingVertical: Int = 0,
		paddingHorizontal: Int = 10,
		height: Int = Int(screenInfo.screenSize.width),
		width: Int = Int(screenInfo.screenSize.width),
		location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: 0),
		navigationAction: @escaping () -> Void = {
			
		
		}) -> SCDWidgetsImage
    {	
    	let image = SCDWidgetsImage()
        
        image.contentPriority = true
        image.content = data
        
        let size = SCDGraphicsDimension()
        size.height = height
        size.width = width        
        image.size = size  
		image.location = location
		image.name = "photoLibrary"

		if paddingHorizontal > 0 {
		image.paddingLeft = paddingHorizontal
		image.size.width = width - paddingHorizontal
		}
		if paddingVertical > 0 {
			image.paddingTop = paddingVertical
		}


        image.onClick { _ in navigationAction() }

        return image
    }

// creates SCDButtons
public func EasySCDButton(
		_ text: String, 
		font: String = "ArialMT",
		color: SCDGraphicsRGB = EasyColor.blue,
		height: Int = 50,
		width: Int = Int(screenInfo.screenSize.width),
		paddingVertical: Int = 0,
		paddingHorizontal: Int = 0,
		location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: 0),
		action: @escaping () -> Void = {  }) -> SCDWidgetsButton
	{	
		let button = SCDWidgetsButton()
		
		button.text = text
		button.font!.fontFamily = font
		button.size = SCDGraphicsDimension(width: width, height: height)
		button.location = location
		button.font!.color = color
		button.onClick { _ in action() }

		if paddingHorizontal > 0 {
			button.paddingLeft = paddingHorizontal
			button.size.width = width - paddingHorizontal
			}
			if paddingVertical > 0 {
				button.paddingTop = paddingVertical
			}

		return button
	}

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

		// tBox.onTextChange.append(SCDWidgetsTextChangeEventHandler{
		// 	ev in form.variable = ev!.newValue			
		// })

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
				text: form.title,
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
			tBox.location = SCDGraphicsPoint(x: 10, y: label.size.height + 5)
			tBox.size = SCDGraphicsDimension(width: width - 20, height: tBox.size.height)
			tBox.font!.size = fontsize
			tBox.font!.color = EasyColor.black


			container.location = location
			container.size = SCDGraphicsDimension(width: width, height: label.size.height + tBox.size.height + 10)
			container.children.append(label)
			container.children.append(tBox)

			elements.append(container)
		}
		return EasyVStack(elements, location: location)
	}


// create SCDVideoViews
public func EasySCDWebView(
		_ url: String, 
		height: Int = Int(screenInfo.screenSize.width),
		width: Int = Int(screenInfo.screenSize.width),
		paddingVertical: Int = 0,
		paddingHorizontal: Int = 10,
		location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: 0)) -> SCDWidgetsWebView
  {
  	
  	let web = SCDWidgetsWebView()
    
    web.size = SCDGraphicsDimension(width: width, height: height)
    web.location = location
	web.backgroundColor = EasyColor.black

	if paddingHorizontal > 0 {
		web.paddingLeft = paddingHorizontal
		web.size.width = width - paddingHorizontal
		}
		if paddingVertical > 0 {
			web.paddingTop = paddingVertical
		}

	web.load(url)
    
    
    // Add event when page loaded
		web.onLoaded.append(SCDWidgetsLoadEventHandler{
			(ev:SCDWidgetsLoadEvent?) in 
			
		
			
			})
		
		
		// Add event when page failed to load
		web.onLoadFailed.append(SCDWidgetsLoadFailedEventHandler{
			(ev:SCDWidgetsLoadFailedEvent?) in 
			
			
			})
	
	web.onShouldLoad.append(SCDWidgetsShouldLoadEventHandler { event in
    // Your logic here, decide whether the web view should load the request
    
    return true  // Return true to allow loading, false to prevent it
})
	
	return web

}

// create SCDVideoViews
public func EasySCDWebView(
		url: String,
		page: SCDWidgetsPage, 
		height: Int = Int(screenInfo.screenSize.width),
		width: Int = Int(screenInfo.screenSize.width),
		paddingVertical: Int = 0,
		paddingHorizontal: Int = 10,
		location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: 0)) -> SCDWidgetsWebView
  {
  	
  	let web = SCDWidgetsWebView()
    
    web.size = SCDGraphicsDimension(width: width, height: height)
    web.location = location
	web.backgroundColor = EasyColor.black

	web.load(url)

	if paddingHorizontal > 0 {
		web.paddingLeft = paddingHorizontal
		web.size.width = width - paddingHorizontal
		}
		if paddingVertical > 0 {
			web.paddingTop = paddingVertical
		}

	page.onEnter.append(
      SCDWidgetsEnterEventHandler {
        (enterPageEvent: SCDWidgetsEnterEvent?) in

		

		 // Add event when page loaded
		web.onLoaded.append(SCDWidgetsLoadEventHandler{
			(ev:SCDWidgetsLoadEvent?) in 

			})
		
		
		// Add event when page failed to load
		web.onLoadFailed.append(SCDWidgetsLoadFailedEventHandler{
			(ev:SCDWidgetsLoadFailedEvent?) in 
				
			})
	
	web.onShouldLoad.append(SCDWidgetsShouldLoadEventHandler { event in
    // Your logic here, decide whether the web view should load the request
    
    return true  // Return true to allow loading, false to prevent it
})


	  }
	)

	page.onExit.append(
      SCDWidgetsExitEventHandler {
        (exitPageEvent: SCDWidgetsExitEvent?) in

		 web.onLoaded.removeAll()
        web.onLoadFailed.removeAll()
        web.onShouldLoad.removeAll()

	  }
	)



	
	return web

}

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
							action: @escaping () -> Void = { }
							) 
							 -> SCDWidgetsContainer
    {	
		let paragraph = splitTextIntoLines(text: text)
		var elements = [SCDWidgetsWidget]()
		
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
			label.horizontalAlignment = SCDLayoutHorizontalAlignment.left    
    		label.baselineAlignment = SCDWidgetsBaselineAlignment.middle
    		label.verticalAlignment = SCDLayoutVerticalAlignment.middle
			label.layoutData = SCDLayoutAutoLayoutData()
			label.size = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: fontsize + 5)

			if paddingHorizontal > 0 {
			label.paddingLeft = paddingHorizontal
			label.size.width -= paddingHorizontal
			}
			if paddingVertical > 0 {
				label.paddingTop = paddingVertical
			}

			elements.append(label)
		}
        
		let stack = EasyVStack(elements: elements, location: SCDGraphicsPoint(x: x_location, y: y_location))
		stack.onClick { _ in action() }
        return stack
    }

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
    let label = EasySCDTextLabel(text: text, fontsize: 20, font: "ArialMT", fontcolor: fontColor, paddingVertical: 0, paddingHorizontal: 10, x_location: 0, y_location: 10)
    let checkbox = EasySCDCheckbox(checked: checked, height: height)
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
	return EasyVStack(elements: elements)
}

// creates a Spacer
public func EasySCDSpacer(_ height: Int = 20) -> SCDWidgetsWidget
{
	return EasySCDTextLabel(text: "", fontsize: height, font: "ArialMT", fontcolor: EasyColor.white, paddingVertical: 0, paddingHorizontal: 0, x_location: 0, y_location: 0)
}


// opens photo library and returns image.content
public func EasySCDCamera(
		_ show: Bool = true,
		onImageLoaded: @escaping (Data) -> Void = { _ in }, // Add this callback 
		sourceType: SCDPlatformCameraSourceType = SCDPlatformCameraSourceType.photolibrary) -> Data
  {
  	let sys = SCDPlatformCamera()
	var imageContent: Data = Data()
  	
	if show {
    
    	sys.getPicture(
    		SCDPlatformCameraOptions.init(sourceType: SCDPlatformCameraSourceType.photolibrary), 
    		onSuccess: SCDPlatformCameraSuccessHandler.init(	{ 
    			data in 

					onImageLoaded(data)
    				imageContent = data
    		}), 
    		onError: SCDPlatformCameraErrorHandler.init(	{ 
    			_ in 
    				EasyAlert(title: "Upload Failed", message: "Failed to attach image.")
    		}))
    
	}
    
       return imageContent
  }


// dynamic vertical arrangement of widgets
public func EasyVStack(_ elements: [SCDWidgetsWidget], location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: Int(screenInfo.statusBarsize.height) + 15)) -> SCDWidgetsContainer {
	let container = SCDWidgetsContainer()
	container.location = location
	
	var yOffset = 0
	for element in elements {
		let tempContainer = SCDWidgetsContainer()
		tempContainer.location = SCDGraphicsPoint(x: Int(element.location.x), y: yOffset)
		tempContainer.size = SCDGraphicsDimension(width: Int(element.size.width), height: Int(element.size.height))
		yOffset += Int(element.size.height) + 10
		tempContainer.children.append(element)
		container.children.append(tempContainer)
	}

	container.size = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: yOffset)
	
	return container
}
// dynamic vertical arrangement of widgets
public func EasyVStack(page: SCDWidgetsPage, elements: [SCDWidgetsWidget], location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: Int(screenInfo.statusBarsize.height) + 15))  {
	let container = SCDWidgetsContainer()
	container.location = location
	
	var yOffset = 0
	for element in elements {
		let tempContainer = SCDWidgetsContainer()
		tempContainer.location = SCDGraphicsPoint(x: Int(element.location.x), y: yOffset)
		tempContainer.size = SCDGraphicsDimension(width: Int(element.size.width), height: Int(element.size.height))
		yOffset += Int(element.size.height) + 10
		tempContainer.children.append(element)
		container.children.append(tempContainer)
	}

	container.size = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: yOffset)
	
	page.children.append(container)
	page.useSafeArea = false
}

public func EasyHStack(page: SCDWidgetsPage, elements: [SCDWidgetsWidget], location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: Int(screenInfo.statusBarsize.height) + 15)
)  {
	let container = SCDWidgetsContainer()
	container.location = location
	
	var xOffset = 0
	for element in elements {
		let tempContainer = SCDWidgetsContainer()
		tempContainer.location = SCDGraphicsPoint(x: xOffset, y: Int(element.location.y))
		tempContainer.size = SCDGraphicsDimension(width: Int(element.size.width), height: Int(element.size.height))
		xOffset += Int(element.size.width) + 10
		tempContainer.children.append(element)
		container.children.append(tempContainer)
	}

	container.size = SCDGraphicsDimension(width: xOffset, height: Int(screenInfo.screenSize.height))
	
	page.children.append(container)
	page.useSafeArea = false
}
public func EasyHStack(_ elements: [SCDWidgetsWidget], location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: Int(screenInfo.statusBarsize.height) + 15)) -> SCDWidgetsContainer
{
	let container = SCDWidgetsContainer()
	container.location = location
	
	var xOffset = 0
	for element in elements {
		let tempContainer = SCDWidgetsContainer()
		tempContainer.location = SCDGraphicsPoint(x: xOffset, y: Int(element.location.y))
		tempContainer.size = SCDGraphicsDimension(width: Int(element.size.width), height: Int(element.size.height))
		xOffset += Int(element.size.width) + 10
		tempContainer.children.append(element)
		container.children.append(tempContainer)
	}

	container.size = SCDGraphicsDimension(width: xOffset, height: Int(screenInfo.screenSize.height))
	
	return container
}

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

public func EasySCDScrollbar() -> SCDSvgScrollGroup
{
	let scroll = SCDSvgScrollGroup()
    scroll.type = SCDSvgScrollType.vertical
    scroll.setScrollBarEnabled(true)
    scroll.height = Int(screenInfo.screenSize.height)
    scroll.width = Int(screenInfo.screenSize.width)
	scroll.visible = true

	let line = SCDSvgLine()
    line.x1 = SCDSvgUnit.init(integerLiteral: Int(screenInfo.screenSize.width - 10))	
    line.x2 = SCDSvgUnit.init(integerLiteral: Int(screenInfo.screenSize.width - 5))	
    line.y1 = SCDSvgUnit.init(integerLiteral: Int(screenInfo.screenSize.height - 10))	
    line.y2 = SCDSvgUnit.init(integerLiteral: Int(screenInfo.screenSize.height - 10))	
    line.visible = true

	scroll.children.append(line)

	return scroll
}

public func EasySCDNavigationBar(
		backgroundColor: SCDGraphicsRGB = EasyColor.white,
		action: @escaping () -> Void = { }) -> SCDWidgetsNavigationBar
  {
  	let navbar = SCDWidgetsNavigationBar()
  	navbar.location = SCDGraphicsPoint(x: 0, y: Int(screenInfo.statusBarsize.height))
	#if os(iOS)
  	navbar.size = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: 60)
	#endif
	#if os(Android)
	navbar.size = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: 50)
	#endif
  	navbar.backgroundColor = backgroundColor
  	navbar.name = "SCDNavigationBar"
  	navbar.children = [
  		EasySCDTextLabel(
    		 		text: "Back", 
    		 		fontsize: 20,
    		 		font: "ArialMT",
					fontcolor:EasyColor.blue,
					paddingVertical:  0,
					paddingHorizontal: 0,
					x_location: Int(screenInfo.screenSize.width / 11),
					y_location: 0,
					action: {
						action()
					})
  	]
  	
  	navbar.onClick { _ in
  		
  		action()

  	}
  	
  	return navbar
  }
public struct EasySCDToolbarItem
  {
  	 var image: String
  	 var action: () -> Void
  }
  
public func EasySCDToolbar(_ items: [EasySCDToolbarItem], height: Int = 50, backgroundColor: SCDGraphicsRGB = EasyColor.gray) -> SCDWidgetsToolBar
    {
    	let toolBar = SCDWidgetsToolBar()
    	
    	//let tBut = SCDWidgetsTabButton()
    	//tBut.active = true
    	//tBut.text = "Home"
    	//tBut.name = "Home"
    	//tBut.size = SCDGraphicsDimension(width: 50, height: 50) 
    	//tBut.backgroundImage
    	
    	toolBar.layout = SCDLayoutAutoLayout() 	  
      	toolBar.backgroundColor = backgroundColor
        toolBar.size = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: height) 
        toolBar.location = SCDGraphicsPoint(x: 0, y: 0)
        
        let div = Int(screenInfo.screenSize.width / CGFloat(items.count))
        let mutli = (items.count) == 5 ? 20 : items.count == 4 ? 25 : items.count == 3 ? 40 : items.count == 2 ? 80 : Int(screenInfo.screenSize.width / 2) - 20       
        var count = 0
        
        for i in items
        {
        	let image = EasySCDImage(
    			path: i.image,
				paddingVertical: 0,
				paddingHorizontal: 0,
				height: 50,
				width: 50,
				location: SCDGraphicsPoint(x: mutli + (div * count), y: 0),
				navigationAction: {
					
      				i.action()
      				
				}
			)
			
			toolBar.children.append(image)

    	count+=1
    	
        }
        
        return toolBar
    }