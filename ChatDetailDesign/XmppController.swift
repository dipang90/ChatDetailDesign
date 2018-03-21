//
//  XmppController.swift
//  ChatDetailDesign
//
//  Created by Binita Modi on 21/08/17.
//  Copyright © 2017 SYNC Technologies. All rights reserved.
//

import UIKit
import XMPPFramework

enum XMPPControllerError: Error {
    case wrongUserJID
}

protocol UpdateTableDelegat {
    func getUpdateTableCell(msgID : String, status : String)
    func  receiveChatMessage(chatObj : ChatMessage, date : String)
}

protocol UpdateUserList {
    func  updateList()
}

protocol UsergroupDelegat {
    func InviteUserToAdd(sender: XMPPRoom)
}

class XmppController : NSObject {
    var xmppStream: XMPPStream
    var xmppMuc:XMPPMUC
    let hostName: String
    let userJID: XMPPJID
    let hostPort: UInt16
    let password: String
    
    var deleget : UpdateTableDelegat?
    var userDelegat : UpdateUserList?
    var userGroupDelegat : UsergroupDelegat?
    
    init(hostName: String, userJIDString: String, hostPort: UInt16 = 5222, password: String) throws {
        
        self.xmppStream = XMPPStream()
        let userJID = XMPPJID(string: userJIDString)
        self.hostName = hostName
        self.userJID = userJID!
        self.hostPort = hostPort
        self.password = password
        
        // Stream Configuration
        self.xmppStream.hostName = hostName
        self.xmppStream.hostPort = hostPort
        self.xmppStream.startTLSPolicy = XMPPStreamStartTLSPolicy.allowed
        self.xmppStream.myJID = userJID
        
        let xmppMessageDeliveryRecipts = XMPPMessageDeliveryReceipts()
        xmppMessageDeliveryRecipts?.autoSendMessageDeliveryRequests = true
        xmppMessageDeliveryRecipts?.autoSendMessageDeliveryReceipts = true
        xmppMessageDeliveryRecipts?.activate(self.xmppStream)
        
        self.xmppMuc = XMPPMUC.init(dispatchQueue: DispatchQueue.main)
        self.xmppMuc.activate(self.xmppStream)
        
        super.init()
        self.xmppMuc.addDelegate(self, delegateQueue: DispatchQueue.main)
        self.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
    }
    
    func connect() {
        if !self.xmppStream.isDisconnected() {
            return
        }
        try! self.xmppStream.connect(withTimeout: XMPPStreamTimeoutNone)
    }
}

//MARK:- Xmpp Stream Delegat. 
/* Create stream first. Based on stream user can connect and used XMPP framework method.*/
extension XmppController: XMPPStreamDelegate {
    
    func xmppStreamDidConnect(_ stream: XMPPStream!) {
        print("Stream: Connected")
        try! stream.authenticate(withPassword:self.password)
    }
    
    func xmppStreamDidDisconnect(_ sender: XMPPStream!, withError error: Error!) {
        
        self.xmppStream.disconnect()
        connect()
    }
    
    func xmppStreamDidAuthenticate(_ sender: XMPPStream!) {
        self.xmppStream.send(XMPPPresence())
        print("Stream: Authenticated")
    }
    
    func xmppStream(_ sender: XMPPStream!, didNotAuthenticate error: DDXMLElement!) {
        print("Stream: Fail to Authenticate")
    }
    
    func xmppStream(_ sender: XMPPStream!, didSend message: XMPPMessage!) {
        
        print("Send Message -> \(message)")
        
        if message.elementID() != nil {
            
            let isStatusChange =  CoredataManager.UpdateChatMassageStatus(msgId: message.elementID(), status: MessageStatus.unsend.rawValue, newStatus: MessageStatus.send.rawValue)
            if isStatusChange {
                deleget?.getUpdateTableCell(msgID: message.elementID(), status: MessageStatus.send.rawValue)
            }
        }
    }
    
    func xmppStream(_ sender: XMPPStream!, didReceive message: XMPPMessage!) {
    
        print("Receive message -> \(message)")
        
        if message.hasReceiptResponse() {
            
            let isStatusChange = CoredataManager.UpdateChatMassageStatus(msgId: message.receiptResponseID(), status: MessageStatus.send.rawValue, newStatus: MessageStatus.deliver.rawValue)
            if isStatusChange {
                 deleget?.getUpdateTableCell(msgID: message.receiptResponseID(), status: MessageStatus.deliver.rawValue)
            }
        } else {
            
            if message.type() != nil {
                if message.type() == "chat"  { //message.type() == "groupchat"
                    if message.body() != nil {
                        receiveMessage(message: message)
                    }
                }
            }
        }
    }
}

//MARk:- Xmpp Room Delegat Metod - Create Room OR Join Room by invited user.
extension XmppController : XMPPRoomDelegate {
    
    func createRoom(groupName : String, arrUser : [String])  {
        
        var strJoin = ""
        for str in arrUser {
            strJoin = "\(strJoin) \(str)"
        }
        
        strJoin =  "\(strJoin)-\(groupName)"
        print("strJoin -> \(strJoin)")
        strJoin = strJoin.trim()
        let roomStorage = XMPPRoomCoreDataStorage.sharedInstance()
        let roomJid = XMPPJID.init(string: "\(groupName)@conference.\(constantVar.hostUrl)")
        let xmppRoom = XMPPRoom.init(roomStorage: roomStorage, jid: roomJid, dispatchQueue: DispatchQueue.main) as XMPPRoom
        xmppRoom.activate(self.xmppStream)
        xmppRoom.addDelegate(self, delegateQueue: DispatchQueue.main)
        xmppRoom.join(usingNickname: self.xmppStream.myJID.user, history: nil, password: nil)
        let messg : XMPPMessage = XMPPMessage.init(name: "groupuserlist")
        messg.addBody(strJoin)
        messg.addSubject(groupName)
        xmppRoom.send(messg)
        
       _ =  CoredataManager.storeGroupUser(groupname: groupName, number: self.xmppStream.myJID.user, username: "", isadmin: true)
        for str in arrUser {
            _ =  CoredataManager.storeGroupUser(groupname: groupName, number: str, username: "", isadmin: false)
        }
        let millisecond = Date().millisecondsSince1970
        let date = DateUtlity.milliscondtoDate(millisecond: millisecond)
        let userupdate = CoredataManager.updateUser(userno:groupName, username: groupName, message:"Group Create", type: "", date: date, time: millisecond, isSender: false,isGroup: true)
        if userupdate {
            userDelegat?.updateList()
        }
    }
    
    func fetchXmppGroup() {
        let server = "conference.\(constantVar.hostUrl)"
        let roomJid = XMPPJID.init(string: server)
        let iq = XMPPIQ.init(type: "get", to: roomJid)
        //iq?.addAttribute(withName: "type", stringValue: "get")
        iq?.addAttribute(withName: "id", stringValue: "chatroom_list")
        iq?.addAttribute(withName: "from", stringValue: self.xmppStream.myJID.bare())
    
        let query = XMLElement.element(withName: "query") as! XMLElement
        query.addAttribute(withName: "xmlns", stringValue:"http://jabber.org/protocol/disco#items")
        
        let storage = XMLElement.element(withName: "storage") as! XMLElement
        storage.elements(forXmlns:"storage:bookmarks")
        //iq?.addChild(storage)
        iq?.addChild(query)
        self.xmppStream.send(iq)
    }
    
    public func xmppRoomDidCreate(_ sender: XMPPRoom!) {
        print("xmppRoomDidCreate")
        sender.fetchConfigurationForm()
    }
    
    public func xmppRoomDidJoin(_ sender: XMPPRoom!) {
        print("xmppRoomDidJoin")
        userGroupDelegat?.InviteUserToAdd(sender: sender)
        //sender.fetchMembersList()
    }
    
    public func xmppRoom(_ sender: XMPPRoom!, didFetchConfigurationForm configForm: DDXMLElement!) {
        print("didFetchConfigurationForm")
        
        let newForm = configForm.copy() as! DDXMLElement
        for field in newForm.elements(forName: "field") {
            if let _var = field.attributeStringValue(forName: "var") {
                switch _var {
                case "muc#roomconfig_persistentroom":
                    field.remove(forName: "value")
                    field.addChild(DDXMLElement(name: "value", numberValue: 1))
                    
                case "muc#roomconfig_membersonly":
                    field.remove(forName: "value")
                    field.addChild(DDXMLElement(name: "value", numberValue: 1))
                    
               // case "muc#roomconfig_moderatedroom":
                //    field.remove(forName: "value")
                //    field.addChild(DDXMLElement(name: "value", numberValue: 1))
                default:
                    break
                }
            }
        }
        
        sender.configureRoom(usingOptions: newForm)
    }
    
    func xmppStream(_ sender: XMPPStream!, didReceive iq: XMPPIQ!) -> Bool {
        
        print("Receive iq -> \(iq)")
        return false
    }
    
    func xmppRoom(_ sender: XMPPRoom!, occupantDidJoin occupantJID: XMPPJID!, with presence: XMPPPresence!) {
    }
    
    func xmppRoom(_ sender: XMPPRoom!, didFetchModeratorsList items: [Any]!) {
        print("didFetchModeratorsList -> \(items)")
    }
    
    func xmppRoom(_ sender: XMPPRoom!, didFetchMembersList items: [Any]!) {
        print("didFetchMembersList -> \(items)")
    }
}
//MARK:- MultiUserchat Deleget Method.
extension XmppController : XMPPMUCDelegate {
    
    func xmppMUC(_ sender: XMPPMUC!, roomJID: XMPPJID!, didReceiveInvitation message: XMPPMessage!) {
        
        print("INvitation -> \(message)")
        
        if message.body() != nil {
        
        let adminuser = message.body()!.components(separatedBy: "@").first
        
        var temp = message.body()!.components(separatedBy: "(")
       
            
        let strVal = temp[1].replacingOccurrences(of: ")", with: "")
        let grp = strVal.trim().components(separatedBy: "-")
        let roomname = grp[1].trim()
        let arr = grp[0].trim().components(separatedBy: " ")
            
        _ =  CoredataManager.storeGroupUser(groupname: roomname, number: adminuser!, username: "", isadmin: true)
            
        print("Array -> \(arr)")
        for strVal in arr {
                _ =  CoredataManager.storeGroupUser(groupname: roomname, number: strVal, username: "", isadmin: false)
        }
        
        let roomStorage = XMPPRoomCoreDataStorage.sharedInstance()
        let xmppRoom = XMPPRoom.init(roomStorage: roomStorage, jid: roomJID, dispatchQueue: DispatchQueue.main) as XMPPRoom
        xmppRoom.activate(self.xmppStream)
        xmppRoom.addDelegate(self, delegateQueue: DispatchQueue.main)
       // xmppRoom.editPrivileges([XMPPRoom.item(withRole: "moderator", jid:roomJID)])
        xmppRoom.join(usingNickname: self.xmppStream.myJID.user, history: nil)
        
        let millisecond = Date().millisecondsSince1970
        let date = DateUtlity.milliscondtoDate(millisecond: millisecond)
        
        let userupdate = CoredataManager.updateUser(userno:roomname, username: roomname, message:"Group Create", type: "", date: date, time: millisecond, isSender: false,isGroup: true)
        
        if userupdate {
            userDelegat?.updateList()
        }
    }
}
    
    func JoinConfrence(newRoom : String) {
        let roomStorage = XMPPRoomCoreDataStorage.sharedInstance()
        let roomJid = XMPPJID.init(string: newRoom)
        let xmppRoom = XMPPRoom.init(roomStorage: roomStorage, jid: roomJid, dispatchQueue: DispatchQueue.main)
        xmppRoom?.activate(self.xmppStream)
        xmppRoom?.addDelegate(self, delegateQueue: DispatchQueue.main)
        xmppRoom?.join(usingNickname: self.xmppStream.myJID.user, history: nil)
    }
}

//MARK:- Controller User Custom Method.
extension XmppController {
    
    func sendMessage(toUser : String, message : String, fromUser : String, isGroup : Bool, arrayUser : [String], groupName : String) -> (ChatMessage, String )  {
        
        let millisecond = Date().millisecondsSince1970
        let date = DateUtlity.milliscondtoDate(millisecond: millisecond)
        let msgId = self.xmppStream.generateUUID()
        
        if isGroup == false {
            
            let body = DDXMLElement.element(withName: MessageSendAttribute.body.rawValue) as! DDXMLElement
            body.stringValue = message
            let message = DDXMLElement.element(withName: MessageSendAttribute.message.rawValue) as! DDXMLElement
            message.addAttribute(withName: MessageSendAttribute.type.rawValue, stringValue: "chat")
            message.addAttribute(withName: MessageSendAttribute.to.rawValue, stringValue: "\(toUser)@\(constantVar.hostUrl)")
            message.addAttribute(withName: MessageSendAttribute.id.rawValue, stringValue: msgId!)
            let msgType = DDXMLElement.element(withName:  MessageSendAttribute.msgtype.rawValue) as! DDXMLElement
            msgType.stringValue = MessageType.text.rawValue
            message.addChild(body)
            message.addChild(msgType)
            self.xmppStream.send(message)
            
            let isSaveObj = CoredataManager.storeChatMessage(id: msgId!, to: toUser, from: fromUser, type: msgType.stringValue!, status: MessageStatus.unsend.rawValue, message: body.stringValue!, time: millisecond, date: date, isSender: true, isPhoto: false, thumbnail: "", photourl: "", photoname: "", thumbnailname: "",isGroup: false)
            
            if isSaveObj {
                let obj = ChatMessage(id: msgId!, to: toUser, from: fromUser, type: msgType.stringValue!, status: MessageStatus.unsend.rawValue, message: body.stringValue!, time: millisecond, date: date, isSender: true, isPhoto: false, photo: ChatPhoto(),isGroup:isGroup)
                return  (obj,date)
            }
            
        } else {
            
            print("arrayUser -> \(arrayUser)")
            
            let array = Array(Set(arrayUser))
            
            print("Remove Duplication -> \(array)")
            
            for strVal in array {
           
               if strVal != self.xmppStream.myJID.user {
                    print("toUser -> \(strVal)")
                    let body = DDXMLElement.element(withName: MessageSendAttribute.body.rawValue) as! DDXMLElement
                    body.stringValue = message
                    let message = DDXMLElement.element(withName: MessageSendAttribute.message.rawValue) as! DDXMLElement
                    message.addAttribute(withName:"from", stringValue: self.xmppStream.myJID.full())
                    message.addAttribute(withName: MessageSendAttribute.type.rawValue, stringValue: "chat")
                    message.addAttribute(withName: MessageSendAttribute.id.rawValue, stringValue: msgId!)
                    message.addAttribute(withName: MessageSendAttribute.to.rawValue, stringValue: "\(strVal)@\(constantVar.hostUrl)")
                    let msgType = DDXMLElement.element(withName: MessageSendAttribute.msgtype.rawValue) as! DDXMLElement
                    msgType.stringValue = MessageType.text.rawValue
                
                    let msgGroup = DDXMLElement.element(withName: "groupname") as! DDXMLElement
                    msgGroup.stringValue = groupName
                    message.addChild(body)
                    message.addChild(msgType)
                    message.addChild(msgGroup)
                    self.xmppStream.send(message)
                
                    }
                }
                
                let isSaveObj = CoredataManager.storeChatMessage(id: msgId!, to: toUser, from: fromUser, type: MessageType.text.rawValue, status: MessageStatus.unsend.rawValue, message: message, time: millisecond, date: date, isSender: true, isPhoto: false, thumbnail: "", photourl: "", photoname: "", thumbnailname: "",isGroup: true)
                
                if isSaveObj {
                    let obj = ChatMessage(id: msgId!, to: toUser, from: fromUser, type: MessageType.text.rawValue, status: MessageStatus.unsend.rawValue, message: message, time: millisecond, date: date, isSender: true, isPhoto: false, photo: ChatPhoto(),isGroup:isGroup)
                    return  (obj,date)
                }
            
        }
        
       return (ChatMessage(),"")
        
        //TODO: Add into database.
    }
    
    func resendUnsendMessage(chatObj : ChatMessage)  {
        
        let body = DDXMLElement.element(withName: MessageSendAttribute.body.rawValue) as! DDXMLElement
        body.stringValue = chatObj.message
        let message = DDXMLElement.element(withName: MessageSendAttribute.message.rawValue) as! DDXMLElement
        message.addAttribute(withName: MessageSendAttribute.type.rawValue, stringValue: "chat")
        message.addAttribute(withName: MessageSendAttribute.to.rawValue, stringValue:"\(chatObj.to)@\(constantVar.hostUrl)")
        message.addAttribute(withName: MessageSendAttribute.id.rawValue, stringValue: chatObj.id!)
        message.addAttribute(withName: MessageSendAttribute.timeSent.rawValue, integerValue: chatObj.time!)
        let msgType = DDXMLElement.element(withName:  MessageSendAttribute.msgtype.rawValue) as! DDXMLElement
        msgType.stringValue = MessageType.text.rawValue
        message.addChild(body)
        message.addChild(msgType)
        self.xmppStream.send(message)
    }
    
    func getPhotoData(toUser : String, fromUser : String, photoUrl : String, thumbnail : String, thumbnailName : String, PhotoName : String,isGroup : Bool ) -> (ChatMessage, String) {
        
        let millisecond = Date().millisecondsSince1970
        let date = DateUtlity.milliscondtoDate(millisecond: millisecond)
        let msgId = self.xmppStream.generateUUID()
        
        let isSave = CoredataManager.storeChatMessage(id: msgId!, to: toUser, from: fromUser, type: MessageType.photo.rawValue, status: MessageStatus.unsend.rawValue, message: "", time: millisecond, date: date, isSender: true, isPhoto: true, thumbnail:thumbnail , photourl: photoUrl, photoname: PhotoName, thumbnailname: thumbnailName,isGroup: isGroup)
        
        if isSave {
            
            print("Save Image to user -> \(toUser)")
            
            let photoObj = ChatPhoto(photoUrl: photoUrl, thumbnail: thumbnail, thumbnailName: thumbnailName, PhotoName: PhotoName)
            
            let obj = ChatMessage(id: msgId!, to: toUser, from: fromUser, type: MessageType.photo.rawValue, status: MessageStatus.unsend.rawValue, message: MessageType.photo.rawValue, time: millisecond, date: date, isSender: true, isPhoto: true, photo: photoObj,isGroup:isGroup)
            
            return (obj,date)
        }
        
        return(ChatMessage(), "")
    }

    
    
    func sendPhoto(toUser : String, messageUrl : String, thumbImageData : String, thumbnaiFile : String, photoFile : String, msgId : String, millisecond: Double, isGroup : Bool, arrayUser : [String], groupName : String) -> (ChatMessage, String)  {
        
        if isGroup == false {
            
            _ = DateUtlity.milliscondtoDate(millisecond: Int(millisecond))
            
            let body = DDXMLElement.element(withName: MessageSendAttribute.body.rawValue) as! DDXMLElement
            body.stringValue = ""
            
            let str : String = thumbImageData.replacingOccurrences(of: "+", with: "($)")
            
            let thumbnail = DDXMLElement.element(withName: "attachment") as! DDXMLElement
            thumbnail.stringValue = thumbImageData
            
            let message = DDXMLElement.element(withName: MessageSendAttribute.message.rawValue) as! DDXMLElement
            message.addAttribute(withName: MessageSendAttribute.type.rawValue, stringValue: "chat")
            message.addAttribute(withName: MessageSendAttribute.to.rawValue, stringValue: "\(toUser)@\(constantVar.hostUrl)")
            //message.addAttribute(withName: "thumbnail", stringValue: thumbImageData)
            
            message.addAttribute(withName: MessageSendAttribute.id.rawValue, stringValue: msgId)
            let msgType = DDXMLElement.element(withName:  MessageSendAttribute.msgtype.rawValue) as! DDXMLElement
            msgType.stringValue = MessageType.photo.rawValue
            message.addChild(body)
            message.addChild(thumbnail)
            message.addChild(msgType)
            self.xmppStream.send(message)
            
        } else {
            
            let array = Array(Set(arrayUser))
            print("Remove Duplication -> \(array)")
            for strVal in array {
                 if strVal != self.xmppStream.myJID.user {
            _ = DateUtlity.milliscondtoDate(millisecond: Int(millisecond))
            
            let body = DDXMLElement.element(withName: MessageSendAttribute.body.rawValue) as! DDXMLElement
            body.stringValue = ""
            
            let str : String = thumbImageData.replacingOccurrences(of: "+", with: "($)")
            
            let thumbnail = DDXMLElement.element(withName: "attachment") as! DDXMLElement
            thumbnail.stringValue = thumbImageData
            
            let message = DDXMLElement.element(withName: MessageSendAttribute.message.rawValue) as! DDXMLElement
            message.addAttribute(withName: MessageSendAttribute.type.rawValue, stringValue: "chat")
            message.addAttribute(withName:"from", stringValue: self.xmppStream.myJID.full())
            message.addAttribute(withName: MessageSendAttribute.to.rawValue, stringValue: "\(strVal)@\(constantVar.hostUrl)")
            message.addAttribute(withName: MessageSendAttribute.id.rawValue, stringValue: msgId)
            let msgType = DDXMLElement.element(withName:  MessageSendAttribute.msgtype.rawValue) as! DDXMLElement
            msgType.stringValue = MessageType.photo.rawValue
            let msgGroup = DDXMLElement.element(withName: "groupname") as! DDXMLElement
            msgGroup.stringValue = groupName
            message.addChild(body)
            message.addChild(thumbnail)
            message.addChild(msgType)
            message.addChild(msgGroup)
            self.xmppStream.send(message)
                    
                }
            }
        }
        
        
        
      /*  let isSaveObj =  CoredataManager.storeChatMessage(id: msgId!, to: toUser, from: "5555555555@\(constantVar.hostUrl)", type: MessageType.photo.rawValue, status: MessageStatus.unsend.rawValue, message: messageUrl, time: millisecond, date: date, isSender: true, isPhoto: true, thumbnail: thumbnaiFile, photo: photoFile)
        
        if isSaveObj { 
         
         from="Optional(&quot;1111111111&quot;)@103.73.190.162"><body/><msgtype>text</msgtype><request xmlns="urn:xmpp:receipts"/><error code="400" type="modify"><bad-request xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/><text xmlns="urn:ietf:params:xml:ns:xmpp-stanzas">Bad value of attribute 'to' in tag &lt;message/&gt; qualified by namespace 'jabber:client'</text></error></message>)
         Send Message -> Optional(<message type="error" to="Optional(&quot;1111111111&quot;)@103.73.190.162"><received xmlns="urn:xmpp:receipts" id="CD6070E7-02BE-4A5E-AF44-9BAA8DC5AB51"/></message>)

            
          /*  let obj = ChatMessage(id: msgId!, to: toUser, from: "5555555555@\(constantVar.hostUrl)", type: MessageType.photo.rawValue, status: MessageStatus.unsend.rawValue, message: messageUrl, time: millisecond, date: date, isSender: true, isPhoto: true, thumbnail: thumbnaiFile, photo: photoFile)
            
            return  (obj,date) */
        } */
        
        return (ChatMessage(),"")
        
        //TODO: Add into database.
    }
    
  //  -(IBAction)sendMessage:(id)sender {
    
    //NSString *messageStr = @”tHIS IS A TEST”;
    
   // UIImage *imagePic = [UIImage imageNamed:@”SmallPaul.png”];
    
  //  if([messageStr length] > 0 || [imagePic isKindOfClass:[UIImage class]] )
    
  //  {
    
  //  NSXMLElement *body = [NSXMLElementelementWithName:@”body”];
    
  //  [body setStringValue:messageStr];
    
  //  NSMutableDictionary *m = [[NSMutableDictionaryalloc] init];
    
   // NSXMLElement *message = [NSXMLElement elementWithName:@”message”];
    
   // [message addAttributeWithName:@”type”stringValue:@”chat”];
    
   // [message addAttributeWithName:@”to”stringValue:self.userInfo];
    
   // [message addChild:body];
    
   // if([imagePic isKindOfClass:[UIImage class]])
    
   // {
    
   // [m setObject:imagePic forKey:@”image”];
    
   // NSData *dataPic =  UIImagePNGRepresentation(imagePic);
    
   // NSXMLElement *photo = [NSXMLElement elementWithName:@”PHOTO”];
    
   // NSXMLElement *binval = [NSXMLElement elementWithName:@”BINVAL”];
    
   // [photo addChild:binval];
    
   // NSString *base64String = [dataPic base64EncodedStringWithOptions:0];
    
   // [binval setStringValue:base64String];
    
   // [message addChild:photo];
    
//}

//[xmppStream sendElement:message];

//}

//}


    func updateSendMessageStatus(messageId : String?, status : String?) {
        
        //TODO: Update The database related to message status
    }
    
    func receiveMessage(message : XMPPMessage) {
        
        let toStr = message.toStr()!.replacingOccurrences(of:"@\(constantVar.hostUrl)", with: "")
        let fromStr =  message.fromStr()!.components(separatedBy: "@")
        
        var fromString = fromStr[0]
        
        let groupnameArray = message.elements(forName: "groupname")
        
        var groupname = ""
        if groupnameArray.count > 0 {
            
            groupname = groupnameArray[0].stringValue!
            print("Group Name -> \(groupname)")
        }
        
        var isGroup = false
        
        if !groupname.isEmpty {
            fromString = groupname
            isGroup = true
        }
        
        var millisecond = Date().millisecondsSince1970
        var date = DateUtlity.milliscondtoDate(millisecond: millisecond)
        
        if message.delayedDeliveryDate() != nil {
             date  = DateUtlity.delayChatTimeInDate(dateAsDate: message.delayedDeliveryDate())
             millisecond = DateUtlity.delayChatTimeInMillisecond(dateAsDate: message.delayedDeliveryDate())
        }
        
        var isPhoto = false
        var imgStr = ""
        var msgType = MessageType.text.rawValue
        let ms = message.elements(forName: MessageSendAttribute.msgtype.rawValue)
        
        let time = Int(Date().millisecondsSince1970)
        let thumbnailName = "\(time)thumb.png"
        let photoName = "\(time)photo.png"
        
        if ms.count > 0 {
            
            if ms[0].stringValue! == MessageType.photo.rawValue {
                
                isPhoto = true
                
                let at = message.elements(forName: "attachment")
                imgStr = at[0].stringValue!
                msgType = MessageType.photo.rawValue
                //let imageData = Data(base64Encoded:imgStr) // Data(base6)  NSData(base64EncodedString: encodedImageData options: .allZeros)
               // let image = UIImage(data: imageData!)
               // ChatImage.saveImageDocumentDirectory(ImageName: photoName, userId: fromStr[0], folderName: PhotoFolderType.Photo.rawValue, image: image!)
                //let imageResize = image?.resizeImage(newWidth: 180)
               // ChatImage.saveImageDocumentDirectory(ImageName: thumbnailName, userId: fromStr[0], folderName: PhotoFolderType.Thumbnail.rawValue, image: image!)
            }
        }
        
        var id = ""
        
        if message.elementID() != nil {
            
            id = message.elementID()!
        }
        
        var receiveMessage = ""
        
        if message.body() != nil {
            
            receiveMessage = message.body().trim()
        }
     
        print(fromString)
        print(msgType)
        print(receiveMessage)
        
        let isSaveObj = CoredataManager.storeChatMessage(id: id, to: toStr, from: fromString, type: msgType, status: "", message: receiveMessage, time: millisecond, date: date, isSender: false, isPhoto: isPhoto, thumbnail: imgStr, photourl: imgStr, photoname: "", thumbnailname: "",isGroup: isGroup)
        
        if isSaveObj {
            var objPhoto = ChatPhoto()
            if ms.count > 0 {
                
                if ms[0].stringValue! == MessageType.photo.rawValue {
                   objPhoto = ChatPhoto(photoUrl: imgStr, thumbnail: imgStr, thumbnailName: thumbnailName, PhotoName: photoName)
                }
            }

            let obj = ChatMessage(id: id, to: toStr, from: fromString, type: msgType, status: "", message: receiveMessage, time: millisecond, date: date, isSender: false, isPhoto: isPhoto, photo: objPhoto,isGroup:isGroup)
            
            print("To User -> \(obj.to) ::: \(fromStr)")
            
            deleget?.receiveChatMessage(chatObj: obj,date: date)
            
            let userupdate = CoredataManager.updateUser(userno: fromString, username: fromString, message: receiveMessage, type: msgType, date: date, time: millisecond, isSender: false,isGroup: isGroup)
            
            if userupdate {
                userDelegat?.updateList()
            }
            
           /* if obj.to == "1234567890" {
                
                deleget?.receiveChatMessage(chatObj: obj,date: date)
                
            } else {
                
                LocalNotification.show(message: obj.message!)
            } */
            
            
        }
    }
}



