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
	let image = EasySCDImageCache(path, path)
	
	let size = SCDGraphicsDimension()
	size.height = height
	size.width = width        
	image.size = size  
	image.location = location
	image.name = "url"
	image.contentPriority = true

	if paddingHorizontal > 0 {
		image.paddingLeft = paddingHorizontal
		image.size.width = width - paddingHorizontal
	}
	if paddingVertical > 0 {
		image.paddingTop = paddingVertical
	}

	
	image.onClick { 
		_ in 
		EasyVibrate()
		navigationAction() 
	}

	return image
}

// 


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
		// cache async
    	let image = EasySCDImageCacheLocal(path, path)
        
        let size = SCDGraphicsDimension()
        size.height = height
        size.width = width        
        image.size = size  
		image.location = location
		image.name = "localPath"
		image.contentPriority = false
		image.url = path

		if paddingHorizontal > 0 {
		image.paddingLeft = paddingHorizontal
		image.size.width = width - paddingHorizontal
		}
		if paddingVertical > 0 {
			image.paddingTop = paddingVertical
		}


        image.onClick { 
			_ in 
			EasyVibrate()
			navigationAction() 
		}

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


        image.onClick { 
			_ in 
			EasyVibrate()
			navigationAction() 
		}

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


        image.onClick { 
			_ in 
			EasyVibrate()
			navigationAction() 
		}

        return image
    }


private func EasySCDImageCache(_ key: String, _ value: String) -> SCDWidgetsImage {
    var imageWidget = SCDWidgetsImage()

    // Try to read the cached picture from storage
    if let picString = appStorage.read(key: key) {
        // Decode the base64 string after stripping the data URI prefix
        let base64String = picString.replacingOccurrences(of: "data:image/png;base64,", with: "")
        if let imageData = Data(base64Encoded: base64String) {
            // Set the image if existing cache data is valid
            imageWidget = EasySCDImageData(imageData)
        }
    }
	else
	{


		if let data = try? Data(contentsOf: URL(string: value)!) {
			let base64String = data.base64EncodedString()
			appStorage.write(key: key, value: base64String)
			imageWidget = EasySCDImageData(data)
		}
	

	}
    return imageWidget
}


private func EasySCDImageCacheLocal(_ key: String, _ filePath: String) -> SCDWidgetsImage {
    var imageWidget = SCDWidgetsImage()

    // Check if the cached version of the file exists and is valid
    if let cachedString = appStorage.read(key: key) {
        let cachedImageData = Data(base64Encoded: cachedString.replacingOccurrences(of: "data:image/png;base64,", with: ""))
        if let imageData = cachedImageData {
            imageWidget = EasySCDImageData(imageData)
        }
    }
	else
	{
		if let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
			let base64String = data.base64EncodedString()
			appStorage.write(key: key, value: base64String)
			imageWidget = EasySCDImageData(data)
		}
	

	}

    return imageWidget
}


actor ImageCacheManager {
    private var imageWidget = SCDWidgetsImage() 

    // Retrieve image from cache or URL
    func loadImageFromURL(_ key: String, url: String) async -> SCDWidgetsImage {

		guard let url = URL(string: url) else {
            // Handle invalid URL case appropriately, perhaps logging the error or using a placeholder image
            return SCDWidgetsImage() // Placeholder or error image
        }

        var imageData: Data?

        // Load from cache
        if let picString = appStorage.read(key: key),
           let cachedData = Data(base64Encoded: picString.replacingOccurrences(of: "data:image/png;base64,", with: "")) {
            imageData = cachedData
        } else if let newImageData = try? Data(contentsOf: URL(string: url)!) {
            // Fetch image data asynchronously and update cache
            let base64String = newImageData.base64EncodedString()
            appStorage.write(key: key, value: "data:image/png;base64," + base64String)
            imageData = newImageData
        }

        // Update image widget within the actor to ensure thread safety
        if let validImageData = imageData {
            self.imageWidget = EasySCDImageData(validImageData)
        }
        return self.imageWidget
    }

    // Retrieve image from cache or local path
    func loadImageFromLocalPath(_ key: String, filePath: String) async -> SCDWidgetsImage {
		guard let fileURL = URL(string: filePath) else {
            return SCDWidgetsImage() // Placeholder or error image
        }
        var imageData: Data?

        // Load from cache
        if let cachedString = appStorage.read(key: key),
           let cachedData = Data(base64Encoded: cachedString.replacingOccurrences(of: "data:image/png;base64,", with: "")) {
            imageData = cachedData
        } else if let newImageData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
            // Fetch image data asynchronously and update cache
            let base64String = newImageData.base64EncodedString()
            appStorage.write(key: key, value: "data:image/png;base64," + base64String)
            imageData = newImageData
        }

        // Update image widget within the actor to ensure thread safety
        if let validImageData = imageData {
            self.imageWidget = EasySCDImageData(validImageData)
        }
        return self.imageWidget
    }
}



// Asynchronously fetch and display the image
func loadAndDisplayImageURL(key: String, url: String, imageView: SCDWidgetsImage) {
    Task {
        let image = await imageCacheManager.loadImageFromURL(key, url: url)
			DispatchQueue.main.async {
            imageView.content = image.content // Update UI on main thread
			}
        
    }
}

private let imageCacheManager = ImageCacheManager()

// Asynchronously fetch and display the image
func loadAndDisplayImage(key: String, filePath: String, imageView: SCDWidgetsImage) {
	Task {
		let image = await imageCacheManager.loadImageFromLocalPath(key, filePath: filePath)
			DispatchQueue.main.async {
			imageView.content = image.content // Update UI on main thread
			}
		
	}
}


// Example usage in your existing functions:
public func EasySCDImageURLAsync(
    _ path: String,
    paddingVertical: Int = 0,
    paddingHorizontal: Int = 10,
    height: Int = Int(screenInfo.screenSize.width),
    width: Int = Int(screenInfo.screenSize.width),
    location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: 0),
    navigationAction: @escaping () -> Void = {}
) -> SCDWidgetsImage {

    var placeholderImage = SCDWidgetsImage()

	loadAndDisplayImageURL(key: path, url: path, imageView: placeholderImage)

	let size = SCDGraphicsDimension()
	size.height = height
	size.width = width        
	placeholderImage.size = size  
	placeholderImage.location = location
	placeholderImage.name = "url"
	placeholderImage.contentPriority = true

	if paddingHorizontal > 0 {
		placeholderImage.paddingLeft = paddingHorizontal
		placeholderImage.size.width = width - paddingHorizontal
	}
	if paddingVertical > 0 {
		placeholderImage.paddingTop = paddingVertical
	}

	
	placeholderImage.onClick { 
		_ in 
		EasyVibrate()
		navigationAction() 
	}

       
    return placeholderImage
}