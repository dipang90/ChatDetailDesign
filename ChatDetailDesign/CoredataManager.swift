//
//  CoredataManager.swift
//  ChatDetailDesign
//
//  Created by Binita Modi on 22/08/17.
//  Copyright © 2017 SYNC Technologies. All rights reserved.
//

import UIKit
import CoreData

class CoredataManager: NSObject {

    private class func getContext () -> NSManagedObjectContext {
        
        let appDeleget = UIApplication.shared.delegate as! AppDelegate
        return appDeleget.persistentContainer.viewContext
    }
    
    class func storeChatMessage(id : String, to:String, from : String, type : String, status : String, message : String, time : Int, date : String, isSender : Bool, isPhoto : Bool, thumbnail : String, photourl : String, photoname : String, thumbnailname : String, isGroup : Bool) -> Bool {
        
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "Simplechat", in: context)
        let managedObj = NSManagedObject(entity: entity!, insertInto: context)
        
        managedObj.setValue(id, forKey: "id")
        managedObj.setValue(to, forKey: "to")
        managedObj.setValue(from, forKey: "from")
        managedObj.setValue(type, forKey: "type")
        managedObj.setValue(status, forKey: "status")
        managedObj.setValue(message, forKey: "message")
        managedObj.setValue(time, forKey: "time")
        managedObj.setValue(date, forKey: "date")
        managedObj.setValue(isSender, forKey: "isSender")
        managedObj.setValue(isPhoto, forKey: "isPhoto")
        managedObj.setValue(thumbnail, forKey: "thumbnail")
        managedObj.setValue(photourl, forKey: "photourl")
        managedObj.setValue(photoname, forKey: "photoname")
        managedObj.setValue(thumbnailname, forKey: "thumbnailname")
        managedObj.setValue(isGroup, forKey: "isGroup")

        do {
            try context.save()
            print("Contxt Saved")
            return true
        } catch {
            print(error.localizedDescription)
        }
        return false
    }
    
    class func fetchChatMassage(time : Int, toUser : String, fromUser : String, isGroup : Bool, groupName : String) -> [ChatMessage] {
        
        var array = [ChatMessage]()
        let context = getContext()
        
        let fetchReques:NSFetchRequest<Simplechat> = Simplechat.fetchRequest()
        fetchReques.fetchLimit = 10
        fetchReques.returnsDistinctResults = true
        if isGroup {
            
            fetchReques.predicate = NSPredicate(format: "time < %@ AND (from == %@ OR to == %@)", argumentArray: [time, groupName, groupName])
            
        } else {
            
            fetchReques.predicate = NSPredicate(format: "time < %@ AND ((from == %@ AND to == %@) OR (from == %@ AND to == %@))", argumentArray: [time, fromUser, toUser, toUser, fromUser])
        }
        
        
        
        print("Fetch Request -> \(fetchReques.predicate)")
        let sortDescriptor = NSSortDescriptor(key: "time", ascending: false)
        fetchReques.sortDescriptors = [sortDescriptor]
        
        do {
            let fetchResult = try context.fetch(fetchReques)
            if let msgTime = fetchResult.last?.time {
                constantVar.chatMessageTime = Int(msgTime)
            }
            for item  in fetchResult {
                
                let photourl = item.photourl ?? ""
                let thumbnail = item.thumbnail ?? ""
                let thumbnailname = item.thumbnailname ?? ""
                let photoname = item.photoname ?? ""
                let id = item.id ?? ""
                let to = item.to ?? ""
                let from = item.from ?? ""
                let type = item.type ?? ""
                let status = item.status ?? ""
                let message = item.message ?? ""
                let date = item.date ?? ""
                
                
                let photoObj = ChatPhoto(photoUrl: photourl, thumbnail: thumbnail, thumbnailName: thumbnailname, PhotoName: photoname)
                
                let msg = ChatMessage(id: id, to: to, from: from, type: type, status: status, message: message, time: Int(item.time), date: date, isSender: item.isSender, isPhoto: item.isPhoto, photo: photoObj, isGroup: item.isGroup)
                
                array.append(msg)
            }
        } catch {
            print(error.localizedDescription)
        }
        return array
    }
    
    class func fetchChatMassageDate(time : Int, toUser : String, fromUser : String, isGroup : Bool, groupName : String) -> [String] {
        
        var array = [String]()
        let context = getContext()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Simplechat")
        fetchRequest.propertiesToFetch = ["date"]
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.includesSubentities = false
        fetchRequest.returnsDistinctResults = true
        fetchRequest.fetchLimit = 10
        
        if isGroup {
            fetchRequest.predicate = NSPredicate(format: "time < %@ AND (from == %@ OR to == %@)", argumentArray: [time, groupName, groupName])
            
        } else {
            fetchRequest.predicate = NSPredicate(format: "time < %@ AND ((from == %@ AND to == %@) OR (from == %@ AND to == %@))", argumentArray: [time, fromUser, toUser, toUser, fromUser])
        }
        
       // fetchRequest.predicate = NSPredicate(format: "time < %@ AND ((from == %@ AND to == %@) OR (from == %@ AND to == %@))", argumentArray: [time, fromUser, toUser, toUser, fromUser])
        let sortDescriptor = NSSortDescriptor(key: "time", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let fetchResult = try context.fetch(fetchRequest)
            
            for item in fetchResult {
                array.append((item as AnyObject).value(forKey: "date") as! String)
            }
            
            } catch {
            print(error.localizedDescription)
        }
        return array
    }
    
    
    class func fetchUnSendChatMassage() -> [ChatMessage] {
        
        var array = [ChatMessage]()
        let context = getContext()
        
        let fetchReques:NSFetchRequest<Simplechat> = Simplechat.fetchRequest()
        fetchReques.predicate = NSPredicate(format: "status == %@", MessageStatus.unsend.rawValue)
        let sortDescriptor = NSSortDescriptor(key: "time", ascending: true)
        fetchReques.sortDescriptors = [sortDescriptor]
        
        do {
            let fetchResult = try context.fetch(fetchReques)
            for item  in fetchResult {
                
                let photourl = item.photourl ?? ""
                let thumbnail = item.thumbnail ?? ""
                let thumbnailname = item.thumbnailname ?? ""
                let photoname = item.photoname ?? ""
                let id = item.id ?? ""
                let to = item.to ?? ""
                let from = item.from ?? ""
                let type = item.type ?? ""
                let status = item.status ?? ""
                let message = item.message ?? ""
                let date = item.date ?? ""
                
                let photoObj = ChatPhoto(photoUrl: photourl, thumbnail: thumbnail, thumbnailName: thumbnailname, PhotoName: photoname)
                
                let msg = ChatMessage(id: id, to: to, from: from, type: type, status: status, message: message, time: Int(item.time), date: date, isSender: item.isSender, isPhoto: item.isPhoto, photo: photoObj,isGroup : item.isGroup)
                
                array.append(msg)
            }
        } catch {
            print(error.localizedDescription)
        }
        return array
    }

    
    class func UpdateChatMassageStatus(msgId : String, status : String, newStatus : String) -> Bool {
       
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Simplechat")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "id == %@ AND status == %@", msgId, status)
        return self.updateContext(fetchRequst: fetchRequest, status: newStatus)
    }
    
    private static func updateContext(fetchRequst : NSFetchRequest<NSFetchRequestResult>, status: String) -> Bool {
        
         let context = getContext()
        
        do {
            let fetchResult = try context.fetch(fetchRequst)
            
            if fetchResult.count > 0 {
                let item = fetchResult[0]
                (item as AnyObject).setValue(status, forKey: "status")
                do {
                    try context.save()
                    print("Contxt Update")
                    return true
                } catch {
                    print(error.localizedDescription)
                }
            }
        } catch {
            print(error.localizedDescription)
        }

        return false
    }
    
    
    class func fetchChatUser() -> [ChatUser] {
        
        var array = [ChatUser]()
        let context = getContext()
        
        let fetchReques:NSFetchRequest<Chatuser> = Chatuser.fetchRequest()
        fetchReques.fetchLimit = 10
        fetchReques.returnsDistinctResults = true
        let sortDescriptor = NSSortDescriptor(key: "time", ascending: false)
        fetchReques.sortDescriptors = [sortDescriptor]
        
        do {
            let fetchResult = try context.fetch(fetchReques)
            if let msgTime = fetchResult.last?.time {
                constantVar.chatMessageTime = Int(msgTime)
            }
            for item  in fetchResult {
                
                let username = item.username ?? ""
                let userno = item.userno ?? ""
                let date  = item.date ?? ""
                let message = item.message ?? ""
                let type = item.type ?? ""
                
                let userObj = ChatUser(userno:userno , username: username, type: type, message: message, time: Int(item.time), date: date, isSender: item.isSender,isGroup : item.isGroup)
                
                array.append(userObj)
            }
        } catch {
            print(error.localizedDescription)
        }
        return array
    }
    
    class func updateUser(userno : String, username : String, message : String, type : String, date : String, time : Int, isSender : Bool, isGroup : Bool) -> Bool {
        
        let context = getContext()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Chatuser")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "userno == %@", userno)
        
        do {
            let fetchResult = try context.fetch(fetchRequest)
            
            if fetchResult.count > 0 {
                let item = fetchResult[0]
                (item as AnyObject).setValue(username, forKey: "username")
                (item as AnyObject).setValue(message, forKey: "message")
                (item as AnyObject).setValue(type, forKey: "type")
                (item as AnyObject).setValue(date, forKey: "date")
                (item as AnyObject).setValue(time, forKey: "time")
                (item as AnyObject).setValue(isSender, forKey: "isSender")
                (item as AnyObject).setValue(isGroup, forKey: "isGroup")
                
                do {
                    try context.save()
                    print("Contxt Update")
                    return true
                } catch {
                    print(error.localizedDescription)
                }
            } else {
                return addNewChatUser(userno: userno, username: username, message: message, type: type, date: date, time: time, isSender: isSender,isGroup: isGroup)
            }
        } catch {
            print(error.localizedDescription)
        }
        return false
    }
    
    class func addNewChatUser(userno : String, username : String, message : String, type : String, date : String, time : Int, isSender : Bool, isGroup : Bool) -> Bool {
        
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "Chatuser", in: context)
        let managedObj = NSManagedObject(entity: entity!, insertInto: context)
        
        managedObj.setValue(userno, forKey: "userno")
        managedObj.setValue(username, forKey: "username")
        managedObj.setValue(message, forKey: "message")
        managedObj.setValue(type, forKey: "type")
        managedObj.setValue(time, forKey: "time")
        managedObj.setValue(date, forKey: "date")
        managedObj.setValue(isSender, forKey: "isSender")
        managedObj.setValue(isGroup, forKey: "isGroup")
        
        do {
            try context.save()
            print("Contxt Saved")
            return true
        } catch {
            print(error.localizedDescription)
        }
        return false
    }
    
    
    class func storeGroupUser(groupname : String, number:String, username : String, isadmin : Bool) -> Bool {
        
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "Groupuser", in: context)
        let managedObj = NSManagedObject(entity: entity!, insertInto: context)
        
        managedObj.setValue(groupname, forKey: "groupname")
        managedObj.setValue(number, forKey: "number")
        managedObj.setValue(username, forKey: "username")
        managedObj.setValue(isadmin, forKey: "isadmin")
        
        do {
            try context.save()
            print("Contxt Saved")
            return true
        } catch {
            print(error.localizedDescription)
        }
        return false
    }
    
    class func fetchGroupUser(groupName : String) -> [String] {
        
        var array = [String]()
        let context = getContext()
        
        let fetchReques:NSFetchRequest<Groupuser> = Groupuser.fetchRequest()
        fetchReques.returnsDistinctResults = true
        fetchReques.predicate = NSPredicate(format: "groupname == %@", groupName)
        let sortDescriptor = NSSortDescriptor(key: "number", ascending: false)
        fetchReques.sortDescriptors = [sortDescriptor]
        
        do {
            let fetchResult = try context.fetch(fetchReques)
            
            for item  in fetchResult {
                let username = item.number ?? ""
                array.append(username)
            }
        } catch {
            print(error.localizedDescription)
        }
        return array
    }

}
