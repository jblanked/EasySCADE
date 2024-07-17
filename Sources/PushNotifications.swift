/*
This uses Supabase and UserNotifications to show a notification when a new message is inserted into the messages table.

You will need a Supabase account and create a table called messages with a column called message.

You will also need to enable push notifications in your app via the Apple Developer Portal.

Within Supabase, you will need your Supabase URL and Supabase Key. You can find these in the API section of your Supabase project.

This code is currently for iOS only.

To use it, add this in your start.swift:

// top of start.swift
#if os(iOS)
import NotificationCenter
import SwiftUI
import UIKit
#endif

// in onFinishLaunching()
#if os(iOS)
@UIApplicationDelegateAdaptor(EasyAppDelegate.self) var appDelegate

Task
{
	// activate did finish launching
    await appDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)
    
    let supabase = Easybase(supabaseURL: "YOUR-URL",supabaseKey: "YOUR_KEY")
    
    await supabase.subscribeToInserts(roomName: "general")
    
}
#endif

*/

#if os(iOS)
import Supabase
import Dispatch
import Foundation
import UserNotifications
import NotificationCenter
import SwiftUI
import UIKit

public class Easybase
{
    private let client: SupabaseClient
    public var title = "New Message"

    public init(supabaseURL: String, supabaseKey: String)
    {
        client = SupabaseClient(supabaseURL: URL(string: supabaseURL)!, supabaseKey: supabaseKey)
    }

    public func signUp(email: String, password: String) async -> Bool
    {
        do
        {
            let response = try await client.auth.signUp(email: email, password: password)
            return true
        }
        catch
        {
            print(error)
            return false
        }
    }

    public func login(email: String, password: String) async -> Bool
    {
        do
        {
            let response = try await client.auth.signIn(email: email, password: password)
            return true
        }
        catch
        {
            print(error)
            return false
        }
    }

    public func logout() async -> Bool
    {
        do
        {
            let response = try await client.auth.signOut()
            return true
        }
        catch
        {
            print(error)
            return false
        }
    }

    public func deleteUser(id: String) async -> Bool
    {
        do
        {
            let response = try await client.auth.admin.deleteUser(id: id)
            return true
        }
        catch
        {
            print(error)
            return false
        }
    }

    public func addMessage(message: String, _ table: String = "messages") async -> Bool
    {
        do
        {
            let message = EasyPushMessage(message: message)
            let response = try await client.from(table).insert(message).execute()
            return true
        }
        catch
        {
            print(error)
            return false
        }
    }

    public func getMessages(_ table: String = "messages") async -> [EasyPushMessage]
    {
        do
        {
            let messages: [EasyPushMessage] = try await client.from(table).select().execute().value
            return messages
        }
        catch
        {
            print(error)
            return []
        }
    }

    public func subscribe(roomName: String) async
    {
        let channel = await client.channel(roomName)
        let broadcastStream = await channel.broadcastStream(event: "cursor-pos")
        await channel.subscribe()

        Task
        {
            for await message in broadcastStream
            {
                print("Cursor position received", message)
            }
        }

        Task
        {
            await channel.broadcast(
                event: "cursor-pos",
                message: [
                    "x": .double(.random(in: 0...1)),
                    "y": .double(.random(in: 0...1))
                ]
            )
        }


    }

   public func subscribeToInserts(roomName: String, table: String = "messages") async 
   {
    let channel = await client.channel(roomName)
    let insertions = await channel.postgresChange(InsertAction.self, schema: "public", table: table)
    await channel.subscribe()

    Task.detached {
        for await insert in insertions {

           if let messageJSON = insert.record["message"] as? AnyJSON {

    		if let messageString = messageJSON.stringValue 
    		{
        		self.showNotification(messageString)
    		} 
    		else 
    		{
        	print("Could not extract string from AnyJSON.")
    		}
    		
		   } 
		   else 
		   {
    		print("Message is not of AnyJSON type.")
			}


        }
    }

    }

    private func showNotification(_ message: String) {
        let content = UNMutableNotificationContent()
        content.title = self.title
        content.body = message
        content.sound = UNNotificationSound.default
        

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }

        }
    
    }
    public func notify(title: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = UNNotificationSound.default
        

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }

        }
    
    }

}

public struct EasyPushMessage: Codable
{ 
  let id = UUID()
  let message: String
}


public class EasyAppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        
        // Request permission to show alerts, play sounds, and set badges
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .providesAppNotificationSettings]) { granted, error in
            if !granted {
                print("Permission for push notifications denied.")
            }
        }
        
        // Set this object as the delegate to handle notifications
        UNUserNotificationCenter.current().delegate = self
        
        // Register to receive remote notifications
        application.registerForRemoteNotifications()
        
        return true
    }

    // This method will be called when a notification is received in the foreground
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        completionHandler([.alert, .badge, .sound])
    }

    // This method will be called when a user interacts with a notification (e.g., taps it)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //print("Notification received with action: \(response.actionIdentifier)")
        completionHandler()
    }

    // Handle registration for remote notifications
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }

    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
}


#endif