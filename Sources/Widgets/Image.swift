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

    // Fetch the image from the provided URL if the cached image is not valid or doesn't exist
    if let profileImageURL = URL(string: value), let newImageData = try? Data(contentsOf: profileImageURL) {
        // Check if the new image data is different from what's already cached and it's not empty
        let newImageBase64String = newImageData.base64EncodedString()
        if appStorage.read(key: key) != newImageBase64String && !newImageData.isEmpty {
            // Save the new image as a base64 string to cache
            appStorage.write(key: key, value: newImageBase64String)
            // Create an image from the newly fetched data and update the widget
            imageWidget = EasySCDImageData(newImageData)
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

    // Check if the local file differs from the cached version or if the cached version is not valid
    if let newImageData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
        let newImageBase64String = newImageData.base64EncodedString()
        if appStorage.read(key: key) != newImageBase64String && !newImageData.isEmpty {
            // Save the new image as a base64 string to cache
            appStorage.write(key: key, value: newImageBase64String)
            // Update the image widget with the new image data
            imageWidget = EasySCDImageData(newImageData)
        }
    }

    return imageWidget
}
actor ImageCacheManager {
    // Retrieve image from cache or URL
    func loadImage(_ key: String, from url: String) async -> SCDWidgetsImage {
        var imageWidget = SCDWidgetsImage()

        // Load from cache
        if let picString = appStorage.read(key: key),
           let imageData = Data(base64Encoded: picString.replacingOccurrences(of: "data:image/png;base64,", with: "")) {
            imageWidget = EasySCDImageData(imageData)
            return imageWidget
        }

        // Fetch from URL if not in cache
        if let profileImageURL = URL(string: url), let newImageData = try? Data(contentsOf: profileImageURL) {
            let newBase64String = newImageData.base64EncodedString()
            if appStorage.read(key: key) != newBase64String {
                appStorage.write(key: key, value: "data:image/png;base64," + newBase64String)
            }
            imageWidget = EasySCDImageData(newImageData)
        }

        return imageWidget
    }
}

private let imageCacheManager = ImageCacheManager()

// Asynchronously fetch and display the image
func loadAndDisplayImage(key: String, url: String, imageView: SCDWidgetsImage) {
    Task {
        let image = await imageCacheManager.loadImage(key, from: url)
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

    let placeholderImage = SCDWidgetsImage()

	loadAndDisplayImage(key: path, url: path, imageView: placeholderImage)

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