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

// Actor for managing image cache and loading
actor ImageCacheManager {
    private var cache: [String: Data] = [:]

    func loadImage(key: String, url: String) async -> Data? {
        if let cachedData = cache[key] {
            return cachedData
        }
        
        guard let imageURL = URL(string: url) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: imageURL)
            cache[key] = data
            return data
        } catch {
            print("Error loading image: \(error)")
            return nil
        }
    }

    func loadLocalImage(key: String, filePath: String) async -> Data? {
        if let cachedData = cache[key] {
            return cachedData
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            cache[key] = data
            return data
        } catch {
            print("Error loading local image: \(error)")
            return nil
        }
    }
}

private let imageCacheManager = ImageCacheManager()

// creates SCDImagelabels from urls
public func EasySCDImageURL(
    _ path: String, 
    paddingVertical: Int = 0,
    paddingHorizontal: Int = 10,
    height: Int = Int(screenInfo.screenSize.width),
    width: Int = Int(screenInfo.screenSize.width),
    location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: 0),
    navigationAction: @escaping () -> Void = {}
) -> SCDWidgetsImage {
    let image = SCDWidgetsImage()
    
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

    // Asynchronously load the image
    Task {
        if let imageData = await imageCacheManager.loadImage(key: path, url: path) {
            DispatchQueue.main.async {
                image.content = imageData
            }
        }
    }

    return image
}


public func EasySCDImage(
    _ path: String, 
    paddingVertical: Int = 0,
    paddingHorizontal: Int = 10,
    height: Int = Int(screenInfo.screenSize.width),
    width: Int = Int(screenInfo.screenSize.width),
    location: SCDGraphicsPoint = SCDGraphicsPoint(x: 0, y: 0),
    navigationAction: @escaping () -> Void = {}
) -> SCDWidgetsImage {
    let image = SCDWidgetsImage()
    
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

    // Asynchronously load the local image
    Task {
        if let imageData = await imageCacheManager.loadLocalImage(key: path, filePath: "Assets/" + path) {
            DispatchQueue.main.async {
                image.content = imageData
            }
        }
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