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

public class EasyTemplateRegistration {
	public var username: String  = ""
    public var password: String = "" 
    public var password2: String = ""
    public var firstName: String = ""
    public var lastName: String = ""
    public var email: String = "" 
    public var onClick: () -> Void = { 
			print("")
			print("Register Button Clicked") 
			print("")
		}


	private func validate() -> Bool {
		if (username.isEmpty || password.isEmpty || password2.isEmpty || firstName.isEmpty || lastName.isEmpty || email.isEmpty) {
			EasyAlert(title: "Registration Error", message: "Please fill in all fields.")
			return false
		}
		if (password != password2) {
			EasyAlert(title: "Registration Error", message: "Passwords do not match.")
			return false
		}
		return true
	}
	
	public init	(
			_ page: SCDLatticePageAdapter,
			_ formNumber: Int = 1,
			name: String = "easyTemplateRegistration", 
			backgroundColor: SCDGraphicsRGB = EasyColor.white
		) {
		
		let userTextbox = EasySCDTextBox("Your Username", secure: false)
   		userTextbox.onTextChange.append(SCDWidgetsTextChangeEventHandler { ev in self.username = ev!.newValue })
   		
   		let emailTextbox = EasySCDTextBox("Your Email", secure: false)
   		emailTextbox.onTextChange.append(SCDWidgetsTextChangeEventHandler { ev in self.email = ev!.newValue })
   		
   		let firstnameTextbox = EasySCDTextBox("Your First Name", secure: false)
   		firstnameTextbox.onTextChange.append(SCDWidgetsTextChangeEventHandler { ev in self.firstName = ev!.newValue })
   
   		let lastnameTextbox = EasySCDTextBox("Your Last Name", secure: false)
   		lastnameTextbox.onTextChange.append(SCDWidgetsTextChangeEventHandler { ev in self.lastName = ev!.newValue })
   		
   		let passTextbox = EasySCDTextBox("Your Password", secure: true)
   		passTextbox.onTextChange.append(SCDWidgetsTextChangeEventHandler { ev in self.password = ev!.newValue })
   
   		let pass2Textbox = EasySCDTextBox("Your Password Again", secure: true)
   		pass2Textbox.onTextChange.append(SCDWidgetsTextChangeEventHandler { ev in self.password2 = ev!.newValue })
   		
   		let buttonRegister: SCDWidgetsButton = EasySCDButton("Register", font: "ArialMT",color: EasyColor.blue)
   		
   		buttonRegister.onClick( 
   			{	
   				_ in 

				if self.validate() {
					self.onClick()
					self.username = ""
					self.email = ""
					self.firstName = ""
					self.lastName = ""
					self.password = ""
					self.password2 = ""
				}
   			}
   		)

		var temp: SCDWidgetsPage = SCDWidgetsPage()		
   
		if formNumber == 1 {
   		
		temp  = EasySCDPage(
			name: name,
			children: [
				EasySCDVStack([
				EasySCDTextForm(
    		
    				[
    			
    				EasySCDTextBoxForm	(
    					title: "Username",
    					textbox: userTextbox				
    				),	
    				EasySCDTextBoxForm	(
    					title: "Email",
    					textbox: emailTextbox  				
    				),
    				EasySCDTextBoxForm	(
    					title: "First Name",
    					textbox: firstnameTextbox  				
    				),
    				EasySCDTextBoxForm	(
    					title: "Last Name",
    					textbox: lastnameTextbox  				
    				),
    				EasySCDTextBoxForm	(
    					title: "Password",
    					textbox: passTextbox  				
    				),
    				EasySCDTextBoxForm	(
    					title: "Password (Again)",
    					textbox: pass2Textbox  				
    				),
    				
    				
    			
    			],
    			
    			fontsize: 20,
				font: "ArialMT", 
				fontcolor: EasyColor.black
    		),
    		buttonRegister
    		])
    		
			],
			useSafeArea: false,
			backgroundColor: backgroundColor,
			onEnter: { },
			onExit: { }
		)

		}
		else if formNumber == 2
		{
			temp  = EasySCDPage(
			name: name,
			children: [
				EasySCDVStack([
					userTextbox,
					emailTextbox,
					firstnameTextbox,
					lastnameTextbox,
					passTextbox,
					pass2Textbox,
					buttonRegister 				
    			])	
    		],
			useSafeArea: false,
			backgroundColor: backgroundColor,
			onEnter: { },
			onExit: { }
		)
		}
		
		page.setTemplate(temp)
	}
}

public class EasyTemplateLogin {
	public var username: String  = ""
	public var password: String = "" 
	public var onClick: () -> Void = { 
			print("")
			print("Sign In Button Clicked") 
			print("")
		}

  	private var scrollbox: SCDSvgScrollGroup = SCDSvgScrollGroup()
  	public var backgroundImage: String = ""

	private func validate() -> Bool {
		if (username.isEmpty || password.isEmpty) {
			EasyAlert(title: "Sign In Error", message: "Please fill in all fields.")
			return false
		}
		return true
	}
	
	public init	(
			_ page: SCDLatticePageAdapter,
			_ formNumber: Int = 1,
			name: String = "easyTemplateSignIn", 
			backgroundColor: SCDGraphicsRGB = EasyColor.white
		) {
		
		let userTextbox = EasySCDTextBox("Your Username", secure: false)
   		userTextbox.onTextChange.append(SCDWidgetsTextChangeEventHandler { ev in self.username = ev!.newValue })
   		
   		let passTextbox = EasySCDTextBox("Your Password", secure: true)
   		passTextbox.onTextChange.append(SCDWidgetsTextChangeEventHandler { ev in self.password = ev!.newValue })
   		
   		let buttonSignIn: SCDWidgetsButton = EasySCDButton("Sign In", font: "ArialMT",color: EasyColor.blue)
   		
   		buttonSignIn.onClick( 
   			{	
   				_ in 

				if self.validate() {
					self.onClick()
					self.username = ""
					self.password = ""
				}
   			}
   		)

		var temp: SCDWidgetsPage = SCDWidgetsPage()	
		
			if formNumber == 1 {	
   		
		temp  = EasySCDPage(
			name: name,
			children: [
				EasySCDVStack([
				EasySCDTextForm(
			
					[
				
					EasySCDTextBoxForm	(
						title: "Username",
						textbox: userTextbox				
					),	
					EasySCDTextBoxForm	(
						title: "Password",
						textbox: passTextbox  				
					),
					
					
				
				],
				
				fontsize: 20,
				font: "ArialMT", 
				fontcolor: EasyColor.black
			),
			buttonSignIn
			])
			
			],
			useSafeArea: false,
			backgroundColor: backgroundColor,
			onEnter: { },
			onExit: { }
		)
		
		}
		
		else if formNumber == 2
		{
			temp  = EasySCDPage(
			name: name,
			children: [
				EasySCDVStack([
				userTextbox,
				passTextbox,				
				buttonSignIn
			])
			
			],
			useSafeArea: false,
			backgroundColor: backgroundColor,
			onEnter: { },
			onExit: { }
		)
		}
		else if formNumber == 3
		{
			self.scrollbox = EasySCDScrollbar(
      							temp, 
      							temp,
      							onPageEnter: {

      							}
      						 )
      						 
    		self.scrollbox.setScrollBarEnabled(false)
    		temp.size = SCDGraphicsDimension(width: Int(screenInfo.screenSize.width), height: Int(screenInfo.screenSize.height))
    		temp.location = SCDGraphicsPoint(x: 0, y: 0)

    		let usernameBox = EasySCDTextBox("Username",secure: false,fontsize: 20,font: "ArialMT",fontcolor: EasyColor.black)

    		usernameBox.onTextChange.append(SCDWidgetsTextChangeEventHandler { ev in self.username = ev!.newValue })

    		usernameBox.backgroundColor = nil

    		let passwordBox = EasySCDTextBox("Password", secure: true, fontsize: 20, font: "ArialMT", fontcolor: EasyColor.black)

    		passwordBox.onTextChange.append(SCDWidgetsTextChangeEventHandler { ev in self.password = ev!.newValue })

    		passwordBox.backgroundColor = nil 
    		
    		let signIn = EasySCDButton(
      						"Sign In",
      						font: "ArialMT",
      						color: EasyColor.black,
      						height: 50,
      						width: Int(screenInfo.screenSize.width),
      						paddingVertical: 0,
      						paddingHorizontal: 0,
      						location: SCDGraphicsPoint(x: 0, y: 0),
      						action: { 
								self.onClick() 
								self.username = ""
								self.password = ""
							}
    					)

    		signIn.cornerRadius = 10

    		let register = EasySCDButton(
      							"Don't have any account? Register here.",
      							font: "ArialMT",
      							color: EasyColor.black,
      							height: 70,
      							width: Int(screenInfo.screenSize.width),
      							paddingVertical: 0,
      							paddingHorizontal: 0,
      							location: SCDGraphicsPoint(x: 0, y: 10),
      							action: { print("Register here button clicked") }
    						)
    		
    		let stack = EasySCDVStack([
      						EasySCDSpacer(Int(screenInfo.screenSize.height / 2.5)),
      						usernameBox,
      						passwordBox,
      						signIn,
      						EasySCDSpacer(150),
      						register,
    					])
			
			temp  = EasySCDPage(
			name: name,
			children: [
				stack
			],
			useSafeArea: false,
			backgroundColor: backgroundColor,
			onEnter: { },
			onExit: { }
		)
		
			if self.backgroundImage != ""
			{
				temp.backgroundImage = self.backgroundImage
			}
			
    		
    		
    		
		}

		page.setTemplate(temp)

		}
}
