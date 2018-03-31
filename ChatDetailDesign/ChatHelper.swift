//
//  ChatHelper.swift
//  chatapp_dipang
//
//  Created by Dipang Shetn on 19/08/17.
//  Copyright © 2017 Dipang iOS. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

enum MessageType : String {
    case text
    case photo 
}

enum MessageStatus : String {
    case unsend  // = "none"
    case send //= "send"
    case deliver //= "deliver"
    case read //= "read"
}

enum MessageUser : String {
    case sender //= "sender"
    case receiver //= "receive"
}

enum MessageSendAttribute : String {
    case to //= "to"
    case type //= "type"
    case id //= "id"
    case timeSent //= "timeSent"
    case body //= "body"
    case msgtype //= "msgtype"
    case message //= "message"
    case thumnail // Image thumbai to shown
}

extension Date {
    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}


struct DateUtlity {
    
    static func milliscondtoDate (millisecond : Int) -> String {
        
        let date = NSDate(timeIntervalSince1970: TimeInterval(millisecond)/1000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.timeZone = TimeZone.current
        let localDate = dateFormatter.string(from: date as Date)
        return localDate
    }
    
    static func milliscondtoTime (millisecond : Int) -> String {
        
        let date = NSDate(timeIntervalSince1970: TimeInterval(millisecond)/1000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.timeZone = TimeZone.current
        let localDate = dateFormatter.string(from: date as Date)
        return localDate
    }
    
    
    static func delayChatTimeInDate(dateAsDate : Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss z"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "dd/MM/yyyy"
       return dateFormatter.string(from: dateAsDate)
    }
    
    
    static func delayChatTimeInTime(dateAsDate : Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss z"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from:dateAsDate)
    }
    
    static func delayChatTimeInMillisecond(dateAsDate : Date) -> Int {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss z"
        dateFormatter.timeZone = TimeZone.current
        return Int(dateAsDate.timeIntervalSince1970) * 1000
    }
    
    static func dateShowninList(millisecond : Int) -> String {
        
        let date = NSDate(timeIntervalSince1970: TimeInterval(millisecond)/1000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss z"
        dateFormatter.timeZone = TimeZone.current
        let calendar = NSCalendar.autoupdatingCurrent
        
        if calendar.isDateInYesterday(date as Date) {
            return "Yesterday"
            
        }  else if calendar.isDateInToday(date as Date){
            return self.milliscondtoTime(millisecond: millisecond)
            
        } else {
            return self.milliscondtoDate(millisecond: millisecond)
        }
    }
}

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in:.whitespacesAndNewlines)
    }
}

enum PhotoFolderType : String {
    case Photo
    case Thumbnail
}


struct DocumentDirctory {
    
    static func getDirectoryPath() -> URL {
         let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory
    }
    
    static func userDirctory(userId : String) -> URL {
        return self.getDirectoryPath().appendingPathComponent(userId)
    }
    
    static func folderDirctory(userId : String, folderName : String) -> URL {
        let userDir = self.userDirctory(userId: userId)
        return userDir.appendingPathComponent(folderName)
    }
}

extension UIImage {
    func resizeImage(newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / self.size.width
        let newHeight = newWidth // self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    } }

struct ChatImage {
    
    static func scaleThumbnailImage(maximumWidth: CGFloat, image : UIImage) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        let cgImage: CGImage = image.cgImage!.cropping(to: rect)!
        let scalImage = UIImage(cgImage: cgImage, scale: image.size.width / maximumWidth, orientation: image.imageOrientation)
        return scalImage
    }

    static func saveImageDocumentDirectory(ImageName : String, userId : String, folderName: String, image : UIImage){
        let fileManager = FileManager.default
        let folderPaths = DocumentDirctory.folderDirctory(userId:userId , folderName: folderName)
        if !fileManager.fileExists(atPath: folderPaths.path) {
            
            do {
                try FileManager.default.createDirectory(atPath: folderPaths.path, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                print("Error creating directory: \(error.localizedDescription)")
            }
        }
        let temp = folderPaths.appendingPathComponent(ImageName)
        if !fileManager.fileExists(atPath: temp.path) {
            do {
                try UIImagePNGRepresentation(image)!.write(to: temp)
            } catch {
                print(error.localizedDescription)
            }
        }
        print("Save Iamge Path -> \(temp)")
    }
    
   static func getImageFromDocumentDirectory(ImageName : String, userId : String, folderName: String) -> URL {
       
        let fileManager = FileManager.default
        let folderPaths = DocumentDirctory.folderDirctory(userId:userId , folderName: folderName)
        let filePath = folderPaths.appendingPathComponent(ImageName)
        return filePath
    }
    
    
    /*
    func deleteImageFromDocumentDirectory(ImageName : String, userId : String, folderName: String) -> Bool {
      
        let paths = DocumentDirctory.folderDirctory(userId:userId , folderName: folderName)+ImageName
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: paths){
            try! fileManager.removeItem(atPath: paths)
            return true
        }
        return false
    }
    
    func deleteDocumentDirectoryUserFolder(userId : String) -> Bool {
        
        let paths = DocumentDirctory.userDirctory(userId: userId)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: paths){
            try! fileManager.removeItem(atPath: paths)
            return true
        }
        return false
    }*/
}

struct LocalNotification {
    
    static func show(message : String) {
        
        let content = UNMutableNotificationContent()
        content.title = "Picture This"
        content.body = message
        content.sound = UNNotificationSound.default()
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: Date())
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate,
                                                    repeats: false)

        let identifier = "UYLLocalNotification"
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound];
        center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                print("Something went wrong")
            }
        }
        
        center.add(request, withCompletionHandler: { (error) in
            if let error = error {
                // Something went wrong
            }
        })
    }
    
}



