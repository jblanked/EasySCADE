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

// SVG colors
public struct EasySVGColor {
	public static let white = SCDColor.init(red: 248, green: 248, blue: 248)
	public static let blue = SCDColor.init(red: 10, green: 132, blue: 255)
	public static let black = SCDColor.init(red: 0, green: 0, blue: 0)
	public static let green = SCDColor.init(red: 48, green: 209, blue: 88) 
	public static let red = SCDColor.init(red: 215, green: 0, blue: 21)
	public static let gray = SCDColor.init(red: 199, green: 199, blue: 204) 
	public static let yellow = SCDColor.init(red: 255, green: 214, blue: 10)
	public static let orange = SCDColor.init(red: 255, green: 159, blue: 10)
	public static let purple = SCDColor.init(red: 191, green: 90, blue: 95)
	public static let pink = SCDColor.init(red: 255, green: 55, blue: 95)
}

// converting string SCDColor to SCDColor
public func EasySCDColor(_ color: String, _ defaultColor: SCDColor = SCDColor.white) -> SCDColor {
	switch color {
		case "SCDColor.white": return SCDColor.white
		case "SCDColor.red": return SCDColor.red
		case "SCDColor.green": return SCDColor.green
		case "SCDColor.black": return SCDColor.black
		case "SCDColor.pink": return SCDColor.pink
		case "SCDColor.orange": return SCDColor.orange
		case "SCDColor.blue": return SCDColor.blue
		case "SCDColor.gray": return SCDColor.gray
		case "SCDColor.yellow": return SCDColor.yellow
		case "SCDColor.purple": return SCDColor.purple	
		case "SCDColor.lightblue": return SCDColor.lightblue
		case "SCDColor.darkgray": return SCDColor.darkgray
		case "SCDColor.lightgreen": return SCDColor.lightgreen
		case "SCDColor.brown": return SCDColor.brown
		case "SCDColor.darkblue": return SCDColor.darkblue
		case "SCDColor.turquoise": return SCDColor.turquoise
		case "SCDColor.lightpink": return SCDColor.lightpink
		case "SCDColor.lightgray": return SCDColor.lightgray
		case "SCDColor.cyan": return SCDColor.cyan
		case "SCDColor.teal": return SCDColor.teal
	    case "SCDColor.darkgreen": return SCDColor.darkgreen
		case "SCDColor.darkred": return SCDColor.darkred
		case "SCDColor.darksalmon": return SCDColor.darksalmon
		case "SCDColor.darkorange": return SCDColor.darkorange
		case "SCDColor.firebrick": return SCDColor.firebrick
		case "SCDColor.deeppink": return SCDColor.deeppink
		case "SCDColor.lightsalmon": return SCDColor.lightsalmon
		case "SCDColor.darkturquoise": return SCDColor.darkturquoise
		case "SCDColor.greenyellow": return SCDColor.greenyellow
		case "SCDColor.deepskyblue": return SCDColor.deepskyblue
		case "SCDColor.whitesmoke": return SCDColor.whitesmoke
		case "SCDColor.grey": return SCDColor.grey
		case "SCDColor.chocolate": return SCDColor.chocolate
		case "SCDColor.honeydew": return SCDColor.honeydew
		case "SCDColor.seagreen": return SCDColor.seagreen
		case "SCDColor.antiquewhite": return SCDColor.antiquewhite
		case "SCDColor.aqua": return SCDColor.aqua
		case "SCDColor.aquamarine": return SCDColor.aquamarine
		case "SCDColor.gold": return SCDColor.gold
		case "SCDColor.hotpink": return SCDColor.hotpink
		case "SCDColor.mintcream": return SCDColor.mintcream
		case "SCDColor.lightsteelblue": return SCDColor.lightsteelblue
		case "SCDColor.tan": return SCDColor.tan
		case "SCDColor.snow": return SCDColor.snow
		case "SCDColor.dimgray": return SCDColor.dimgray
		case "SCDColor.silver": return SCDColor.silver
		case "SCDColor.springgreen": return SCDColor.springgreen
		case "SCDColor.lightcyan": return SCDColor.lightcyan
		case "SCDColor.lavender": return SCDColor.lavender
		case "SCDColor.orangered": return SCDColor.orangered
		case "SCDColor.mediumblue": return SCDColor.mediumblue
		case "SCDColor.lightyellow": return SCDColor.lightyellow
		case "SCDColor.midnightblue": return SCDColor.midnightblue
		case "SCDColor.powderblue": return SCDColor.powderblue
		case "SCDColor.floralwhite": return SCDColor.floralwhite
			
		default: return defaultColor
		
	}
}

public func EasySVGColorToRGB(_ svgColor: SCDColor) -> SCDGraphicsRGB
{
   var color: SCDGraphicsRGB
   
   switch(svgColor)
   {
   		case SCDColor.white: 	color = EasyColor.white; 	
   		case SCDColor.red: 		color = EasyColor.red; 		
   		case SCDColor.green:	color = EasyColor.green; 	
   		case SCDColor.black:	color = EasyColor.black; 	
   		case SCDColor.pink:		color = EasyColor.pink; 		
   		case SCDColor.orange:	color = EasyColor.orange; 	
   		case SCDColor.blue:		color = EasyColor.blue; 	
   		case SCDColor.gray:		color = EasyColor.gray; 	
   		case SCDColor.yellow:	color = EasyColor.yellow; 	
   		case SCDColor.purple:	color = EasyColor.purple; 	
   		
   		default: color = SCDGraphicsRGB.init(red: svgColor.red, green: svgColor.green, blue: svgColor.blue)
   }
   
   return color
}

public func EasyRGBColorToSVG(_ rgbColor: SCDGraphicsRGB) -> SCDColor
{
   var color2: SCDColor
   
   switch(rgbColor)
   {
   		case EasyColor.white: 	color2 = EasySVGColor.white;
   		case EasyColor.red:		color2 = EasySVGColor.red;
   		case EasyColor.green: 	color2 = EasySVGColor.green;
   		case EasyColor.black: 	color2 = EasySVGColor.black;
   		case EasyColor.pink: 	color2 = EasySVGColor.pink;
   		case EasyColor.orange: 	color2 = EasySVGColor.orange;
   		case EasyColor.blue: 	color2 = EasySVGColor.blue;
   		case EasyColor.gray:	color2 = EasySVGColor.gray;
   		case EasyColor.yellow: 	color2 = EasySVGColor.yellow;
   		case EasyColor.purple: 	color2 = EasySVGColor.purple;
   		
   		default: color2 = SCDColor.init(red: rgbColor.red, green: rgbColor.green, blue: rgbColor.blue)
   }
   
   return color2
}

public func EasySCDSvgRGBColorToRGB(_ svgColor: SCDSvgRGBColor) -> SCDGraphicsRGB
{
   return SCDGraphicsRGB.init(red: svgColor.red, green: svgColor.green, blue: svgColor.blue)
}

#if os(iOS)
// convert EasyColor to UIColor
public func EasyColorToUIColor(_ color: SCDGraphicsRGB) -> UIColor {
	
	var color2: UIColor

	switch(color)
	{
		case EasyColor.white: 	color2 = UIColor.white
		case EasyColor.red:		color2 = UIColor.red
		case EasyColor.green: 	color2 = UIColor.green
		case EasyColor.black: 	color2 = UIColor.black
		case EasyColor.pink: 	color2 = UIColor.systemPink
		case EasyColor.orange: 	color2 = UIColor.orange
		case EasyColor.blue: 	color2 = UIColor.blue
		case EasyColor.gray:	color2 = UIColor.systemGray
		case EasyColor.yellow: 	color2 = UIColor.systemYellow
		case EasyColor.purple: 	color2 = UIColor.systemPurple
		
		default: color2 = UIColor.init(red: CGFloat(color.red), green: CGFloat(color.green), blue: CGFloat(color.blue), alpha: 1.0)
	}
}

// convert UIColor to EasyColor
public func UIColorToEasyColor(_ color: UIColor) -> SCDGraphicsRGB {
	
	var color2: SCDGraphicsRGB

	switch(color)
	{
		case UIColor.white: 	color2 = EasyColor.white
		case UIColor.red:		color2 = EasyColor.red
		case UIColor.green: 	color2 = EasyColor.green
		case UIColor.black: 	color2 = EasyColor.black
		case UIColor.systemPink: 	color2 = EasyColor.pink
		case UIColor.orange: 	color2 = EasyColor.orange
		case UIColor.blue: 	color2 = EasyColor.blue
		case UIColor.systemGray:	color2 = EasyColor.gray
		case UIColor.systemYellow: 	color2 = EasyColor.yellow
		case UIColor.systemPurple: 	color2 = EasyColor.purple
		
		default: color2 = SCDGraphicsRGB.init(red: Int(color.redValue), green: Int(color.greenValue), blue: Int(color.blueValue))
	}
}

#endif