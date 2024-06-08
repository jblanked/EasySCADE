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

//import SQLite

// public class EasyAppStorage {
    
//     private let db: Connection
//     private let keyValueTable = Table("key_value_store")
//     private let key = Expression<String>("key")
//     private let value = Expression<String>("value")
    
//     // Initialize the database connection
//     public init() {
//         do {
//             let path = NSHomeDirectory() + "/data.db"
//             db = try Connection(path)
//             try createTable()
//         } catch {
//             fatalError("Failed to initialize database connection: \(error)")
//         }
//     }
    
//     // Create the key-value table
//     private func createTable() throws {
//         try db.run(keyValueTable.create(ifNotExists: true) { t in
//             t.column(key, primaryKey: true)
//             t.column(value)
//         })
//     }
    
//     // Write a key-value pair
//     public func write(key: String, value: String) {
//         do {
//             let insert = keyValueTable.insert(or: .replace, self.key <- key, self.value <- value)
//             try db.run(insert)
//         } catch {
//             print("Failed to write key-value: \(error)")
//         }
//     }
    
//     // Read a value by key
//     public func read(key: String) -> String? {
//         do {
//             if let row = try db.pluck(keyValueTable.filter(self.key == key)) {
//                 return row[self.value]
//             }
//         } catch {
//             print("Failed to read key: \(error)")
//         }
//         return nil
//     }
    
//     // Delete a key-value pair
//     public func delete(key: String) {
//         do {
//             let row = keyValueTable.filter(self.key == key)
//             try db.run(row.delete())
//         } catch {
//             print("Failed to delete key: \(error)")
//         }
//     }

// 	// Delete all key-value pairs
// 	public func deleteAllKeys() {
// 		do {
// 			try db.run(keyValueTable.delete())
// 		} catch {
// 			print("Failed to delete all keys: \(error)")
// 		}
// 	}
// }

public class EasyAppStorage {
    
    #if os(iOS)
    // iOS UserDefaults as the storage medium
    #elseif os(Android)
    // Android SharedPreferences as the storage medium
    private var sharedPreferences: AndroidContent.SharedPreferences?
    #endif
    
    public init() {
        #if os(Android)
        sharedPreferences = Application.currentActivity?.getSharedPreferences(name: "EasySCADE", mode: 0)
        #endif
    }
    
    public func write(key: String, value: String) {
        #if os(Android)
        let editor = sharedPreferences?.edit()
        editor?.putString(key: key, value: value)
        editor?.apply()
        #else
        UserDefaults.standard.set(value, forKey: key)
        #endif
    }
    
    public func read(key: String) -> String? {
        #if os(Android)
        return sharedPreferences?.getString(key: key, defValue: "")
        #else
        return UserDefaults.standard.string(forKey: key)
        #endif

    }
    
    public func delete(key: String) {
        #if os(Android)
        let editor = sharedPreferences?.edit()
        editor?.remove(key: key)
        editor?.apply()
        #else
        UserDefaults.standard.removeObject(forKey: key)
        #endif
    }
    
    public func deleteAllKeys() {
        #if os(Android)
        let editor = sharedPreferences?.edit()
        editor?.clear()
        editor?.apply()
        #else
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }
        #endif
    }
}


public let appStorage: EasyAppStorage = EasyAppStorage()