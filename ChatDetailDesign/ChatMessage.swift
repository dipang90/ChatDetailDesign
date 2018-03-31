//
//  ChatMessage.swift
//  ChatDetailDesign
//
//  Created by Dipang Shetn on 19/08/17.
//  Copyright © 2017 Dipang iOS. All rights reserved.
//

import UIKit

class ChatMessage {

    var id : String?                // Primary Key
    var to : String?                // text, photo
    var from : String?              // sender, receiver
    var type : String?
    var status : String?
    var message : String?           // Message Day Which fillter with day.
    var time : Int?
    var date : String?
    var isSender : Bool?            // Login USer Id
    var isPhoto : Bool?
    var photo : ChatPhoto?
    var isGroup : Bool?
    

    
    init(id : String, to:String, from : String, type : String, status : String, message : String, time : Int, date : String, isSender : Bool, isPhoto : Bool, photo : ChatPhoto, isGroup : Bool) {
        
        self.id = id
        self.to = to
        self.from = from
        self.type = type
        self.status = status
        self.message = message
        self.time = time
        self.date = date
        self.isSender = isSender
        self.isPhoto = isPhoto
        self.photo = photo
        self.isGroup = isGroup
    }
    
    init() { }
}

// when Photo is upload Below parameter are use else nil.
class ChatPhoto  {
    
    var photoUrl : String?
    var thumbnail : String?
    var thumbnailName: String?
    var PhotoName : String?
    
    init(photoUrl : String, thumbnail:String, thumbnailName : String, PhotoName : String) {
        
        self.photoUrl = photoUrl
        self.thumbnail = thumbnail
        self.thumbnailName = thumbnailName
        self.PhotoName = PhotoName
    }
    
    init() { }
}

class ChatUser {
    
    var userno : String?
    var username : String?
    var type : String?
    var message : String?
    var time : Int?
    var date : String?
    var isSender : Bool?
    var isGroup : Bool?
    
    init(userno : String,username : String,type : String,message : String,time : Int,date : String, isSender : Bool, isGroup : Bool ) {
        
        self.userno = userno
        self.username = username
        self.type = type
        self.date = date
        self.isSender = isSender
        self.message = message
        self.time = time
        self.isGroup = isGroup
    }
    
    init() {
        
    }
}

