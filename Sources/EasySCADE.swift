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
let easyProgress: ProgressDialog = ProgressDialog(context: Application.currentActivity!)
#endif

// stores the screen information
public let screenInfo: EasyScreenInfo = getWindowScreenSize()


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


// creates an alert 
public func EasyAlert(title:String, message:String,action: @escaping () -> Void = { }) {

	DispatchQueue.main.async {

    #if os(iOS)

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

	//   let listener = DialogInterfaceOnClickListener.onClick {
	// 	(dialog, 0) in action()
	// 	}
	  builder.setPositiveButton(text: "OK", listener: nil)

	  let dialog: AlertDialog = builder.create()!

	  dialog.show()
	  
	#endif
      
	
	}

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
			var spinner: UIActivityIndicatorView
			if #available(iOS 13.0, *) {
         	spinner = UIActivityIndicatorView(style: .large)
			} else {
			 spinner = UIActivityIndicatorView(style: .whiteLarge)
			}
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


public func EasySpinner(_ seconds: Int, _ text: String = "Loading...", _ action: @escaping () -> Void = { }) {
	DispatchQueue.main.async {
		EasySpinner(true, text)
		DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds)) {
    		EasySpinner(false)
			action()
		}
	}
}


public func EasySwipeGesture(
		_ page: SCDWidgetsPage,
		_ direction: SCDSvgSwipeDirection = .right,
		_ action: @escaping () -> Void = { print("swiped") }
		)  {
		
		// Use short cut syntax to create recognizer and specify action
		let swipeGestureRecognizer = SCDSvgSwipeGestureRecognizer { handler in
    		
    		action()
    		
		}
		// Configure: capture swifts from left to right only
		swipeGestureRecognizer.direction = direction
		
		page.drawing!.gestureRecognizers.append(swipeGestureRecognizer)
	}
// add the gesture to the widget after the widget has been added to the page so that the recognizer will use the entire length of the widget instead of just the original page size
public func EasySwipeGesture(
		_ widget: SCDWidgetsWidget,
		_ direction: SCDSvgSwipeDirection = .right,
		_ action: @escaping () -> Void = { print("swiped") }
		)  {
		
		// Use short cut syntax to create recognizer and specify action
		let swipeGestureRecognizer = SCDSvgSwipeGestureRecognizer { handler in
    		
    		action()
    		
		}
		// Configure: capture swifts from left to right only
		swipeGestureRecognizer.direction = direction
		
		widget.drawing!.gestureRecognizers.append(swipeGestureRecognizer)
	}


// creates a Spacer
public func EasySCDSpacer(_ height: Int = 20) -> SCDWidgetsWidget
{
	let sp = EasySCDTextLabel("", fontsize: height, font: "ArialMT", fontcolor: EasyColor.white, paddingVertical: height, paddingHorizontal: 0, x_location: 0, y_location: 0)
	sp.size = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: height)
	return sp
}


public func EasySCDSeperator(_ y: Int = 20, _ strokeColor: SCDSvgColor = EasySVGColor.black, _ strokeWidth: Float = 1.0) -> SCDWidgetsWidget
  {
  	let line = SCDSvgLine()
    line.x1 = SCDSvgUnit(integerLiteral: 10)
    line.y1 = SCDSvgUnit(integerLiteral: y)
    line.x2 = SCDSvgUnit(integerLiteral: Int(screenInfo.screenSize.width) - 10)
    line.y2 = SCDSvgUnit(integerLiteral: y)

    // Setting the stroke color and width to make the line visible
    line.stroke = strokeColor // Black color
    line.strokeWidth = strokeWidth // Adjust stroke width as needed

    let group = SCDSvgGroup()
    group.children.append(line)
    
    let Label = SCDWidgetsLabel()
    Label.size = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: y)
    Label.location = SCDGraphicsPoint(x: 0, y: 0)
    Label.drawing = group // Set the SVG drawing
  	
  	return Label
  }

// creates a SCDGraphicsFont
public func EasyFont(
    _ size: Int = 20,
  	_ name: String = "ArialMT",
  	_ color: SCDGraphicsRGB = EasyColor.black,
  	_ bold: Bool = false,
  	_ underline: Bool = false,
  	_ italic: Bool = false,
  	_ lineThrough: Bool = false 	
  ) -> SCDGraphicsFont
  {
  	let f: SCDGraphicsFont = SCDGraphicsFont()
    	 
    f.bold = bold
    f.color = color
    f.italic = italic
    f.lineThrough = lineThrough
    f.underline = underline
    f.size = size
    
    return f
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