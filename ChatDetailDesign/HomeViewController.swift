//
//  HomeViewController.swift
//  ChatDetailDesign
//
//  Created by Binita Modi on 31/08/17.
//  Copyright © 2017 SYNC Technologies. All rights reserved.
//
import XMPPFramework
import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UpdateUserList, UserListFromSendMessage {

    @IBOutlet weak var tableViewChatUser: UITableView!
    
    var arrayChatUser = [ChatUser]()
    var xmppHelper : XmppController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableViewChatUser.register(UINib(nibName: "ChatUserTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatUserTableViewCell")
        self.tableViewChatUser.delegate = self
        self.tableViewChatUser.dataSource = self
        arrayChatUser = CoredataManager.fetchChatUser()
        tableViewChatUser.tableFooterView = UIView()
        
        DispatchQueue.main.async {
            self.tableViewChatUser.reloadData()
        }
        
        xmppHelper = getXmppHelper()
        xmppHelper.userDelegat = self
        
        let button1 = UIButton.init(type: .custom)
        button1.setImage(#imageLiteral(resourceName: "sendmsg"), for: UIControlState.normal)
        button1.addTarget(self, action: #selector(createAlbumClick), for: UIControlEvents.touchUpInside)
        button1.frame = CGRect(x: 0, y: 0, width: 20 , height: 20 )
        let barButton1 = UIBarButtonItem(customView: button1)
        self.navigationItem.rightBarButtonItem = barButton1
        
        //creategroup
        // Do any additional setup after loading the view.
    }
    
    func createAlbumClick()  {
        
        let varStroryboad = UIStoryboard.init(name:"Main", bundle: nil)
        let objDraw   = varStroryboad.instantiateViewController(withIdentifier: "creategroup") as? CreateGroupViewController
        let nac = UINavigationController.init(rootViewController: objDraw!)
        self.navigationController?.present(nac, animated: true, completion: {
            
            
        })
    }
    
    func getXmppHelper () -> XmppController {
        
        let appDeleget = UIApplication.shared.delegate as! AppDelegate
        return appDeleget.xmppHelper
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayChatUser.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatUserTableViewCell", for: indexPath) as! ChatUserTableViewCell
        
        let obj = arrayChatUser[indexPath.row]
        cell.lblTitle.text = "AB"
        cell.lblContact.text = obj.username! as String
        cell.lblMessage.text = obj.message
        cell.lblDate.text = DateUtlity.dateShowninList(millisecond: obj.time!)
        cell.imgSendStatus.isHidden = false
        if (obj.message?.isEmpty)! {
            cell.imgSendStatus.isHidden = true
        }
        
        cell.imgSendStatus.image = #imageLiteral(resourceName: "down-arrow") // UIImage(named: #imageLiteral(resourceName: "up-arrow"))
        
        if obj.isSender!{
            
            cell.imgSendStatus.image = #imageLiteral(resourceName: "up-arrow")  //UIImage(named: #imageLiteral(resourceName: "down-arrow"))
        }
        
        if obj.type == MessageType.photo.rawValue {
            cell.lblMessage.text = "Photo received"
            if obj.isSender == true {
                cell.lblMessage.text = "Photo sent"
            }
        }
        
        print("Group -> \(obj.isGroup)")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //self.xmppHelper.createRoom(groupName: "test12356789")
        
       // self.xmppHelper.fetchXmppGroup()
        
       // self.xmppHelper.fetchXmppGroup()
        
      let obj = arrayChatUser[indexPath.row]
        let varStroryboad = UIStoryboard.init(name:"Main", bundle: nil)
        let objPhotoPreview = varStroryboad.instantiateViewController(withIdentifier: "chatid") as? ViewController
        objPhotoPreview?.isGroupChat = obj.isGroup!
        objPhotoPreview?.updateSendListDelegat = self
        objPhotoPreview?.userid = obj.userno! as String
         objPhotoPreview?.userName = obj.username! as String
        
        print("User NAme -> \(obj.username!)")
        
        self.navigationController?.pushViewController(objPhotoPreview!, animated: true)
        
      /*  let msgId = self.xmppHelper.xmppStream.generateUUID()
        
        let body = DDXMLElement.element(withName: MessageSendAttribute.body.rawValue) as! DDXMLElement
        body.stringValue = "Hello How r u"
        let message = DDXMLElement.element(withName: MessageSendAttribute.message.rawValue) as! DDXMLElement
        message.addAttribute(withName: MessageSendAttribute.type.rawValue, stringValue: "groupchat")
        message.addAttribute(withName: "from", stringValue: self.xmppHelper.xmppStream.myJID.bare())
        message.addAttribute(withName: MessageSendAttribute.id.rawValue, stringValue: msgId!)
        //message.addAttribute(withName: MessageSendAttribute.timeSent.rawValue, integerValue: millisecond)
        let msgType = DDXMLElement.element(withName:  MessageSendAttribute.msgtype.rawValue) as! DDXMLElement
        msgType.stringValue = MessageType.text.rawValue
        message.addChild(body)
        message.addChild(msgType)
        //self.xmppHelper.xmppStream.send(message)
        
        let msg = XMPPMessage.init(from: message) as XMPPMessage
        let roomStorage = XMPPRoomCoreDataStorage.sharedInstance()
        let roomJid = XMPPJID.init(string: "hellowq@conference.\(constantVar.hostUrl)")
        let xmppRoom = XMPPRoom.init(roomStorage: roomStorage, jid: roomJid, dispatchQueue: DispatchQueue.main) as XMPPRoom
        xmppRoom.activate(self.xmppHelper.xmppStream)
        xmppRoom.addDelegate(self, delegateQueue: DispatchQueue.main)
        xmppRoom.send(msg) */

    }
    
    func updateList() {
        arrayChatUser.removeAll()
        arrayChatUser = CoredataManager.fetchChatUser()
        DispatchQueue.main.async {
            self.tableViewChatUser.reloadData()
        }
    }
    
    func updateUserFromSendMessage() {
        
        arrayChatUser.removeAll()
        arrayChatUser = CoredataManager.fetchChatUser()
        DispatchQueue.main.async {
            self.tableViewChatUser.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Xmpp Room 
    
    func createRoom()  {
        
   // let roomJid = XMPPJID.init(string: "1111111111@\(constantVar.hostUrl)")
        
     let roomStorage = XMPPRoomCoreDataStorage.sharedInstance()
     let roomJid = XMPPJID.init(string: "YahhoBySyncInc@conference.\(constantVar.hostUrl)")
     let xmppRoom = XMPPRoom.init(roomStorage: roomStorage, jid: roomJid, dispatchQueue: DispatchQueue.main)
     xmppRoom?.activate(self.xmppHelper.xmppStream)
     xmppRoom?.addDelegate(self, delegateQueue: DispatchQueue.main)
     xmppRoom?.join(usingNickname: "iOSDveloper1", history: nil, password: "5555555555")
    }
    
    func grupChat() {
        
        let roomJid = XMPPJID.init(string: "5555555555@\(constantVar.hostUrl)")
        let iq = XMPPIQ.init(type: "get", to: roomJid)
        iq?.addAttribute(withName: "id", stringValue: "chatroom_list")
        iq?.addAttribute(withName: "from", stringValue: self.xmppHelper.xmppStream.myJID.full())
        
        let query = XMLElement.element(withName: "query") as! XMLElement
        query.addAttribute(withName: "xmlns", stringValue:"http://jabber.org/protocol/disco#items")
        iq?.addChild(query)
        self.xmppHelper.xmppStream.send(iq)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
/*
extension HomeViewController : XMPPRoomDelegate {
    
    public func xmppRoomDidCreate(_ sender: XMPPRoom!) {
        print("xmppRoomDidCreate")
        
        // I prefer configure right after created
        sender.fetchConfigurationForm()
    }
    
    public func xmppRoomDidJoin(_ sender: XMPPRoom!) {
        print("xmppRoomDidJoin")
        
        let roomJid = XMPPJID.init(string: "1111111111@\(constantVar.hostUrl)")
        let roomJid1 = XMPPJID.init(string: "1234567890@\(constantVar.hostUrl)")
        sender.inviteUsers([roomJid!,roomJid1!], withMessage: "Hello Join Group")
        
       // Optional(<message to="sync@conference.103.73.190.162"><x xmlns="http://jabber.org/protocol/muc#user"><invite to="1111111111@103.73.190.162"><reason>Hello Join</reason></invite></x></message>)
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
     
     // other configures
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
    
} */


/*<iq xmlns="jabber:client"
to="1234567890@103.73.190.162/58335741949500689505106"
from="conference.103.73.190.162"
type="result"
id="34D6FA1F-1CF2-4635-B09D-31C4ADDDCFB8">
<query xmlns="http://jabber.org/protocol/disco#items">
<item name="0123syncdev2321ert235 (0)" jid="0123syncdev2321ert235@conference.103.73.190.162"/>
<item name="12120123syncdev2321ert235 (0)" jid="12120123syncdev2321ert235@conference.103.73.190.162"/>
<item name="26yuoo5bdrv0k (private, 0)" jid="26yuoo5bdrv0k@conference.103.73.190.162"/>
<item name="322egsusuc3la (private, 0)" jid="322egsusuc3la@conference.103.73.190.162"/>
<item name="38syhw4bax0fl (private, 0)" jid="38syhw4bax0fl@conference.103.73.190.162"/>
<item name="3n1l26twe24t2 (private, 0)" jid="3n1l26twe24t2@conference.103.73.190.162"/>
<item name="3tcipazanlpsk (private, 0)" jid="3tcipazanlpsk@conference.103.73.190.162"/>
<item name="8dn397l1qf5i (private, 0)" jid="8dn397l1qf5i@conference.103.73.190.162"/>
<item name="googleinc (0)" jid="googleinc@conference.103.73.190.162"/>
<item name="iosdveloper (0)" jid="iosdveloper@conference.103.73.190.162"/>
<item name="ofj525qmdw6k (private, 0)" jid="ofj525qmdw6k@conference.103.73.190.162"/>
<item name="sync (0)" jid="sync@conference.103.73.190.162"/>
<item name="sync1 (0)" jid="sync1@conference.103.73.190.162"/>
<item name="synctechnologies (0)" jid="synctechnologies@conference.103.73.190.162"/>
<item name="test123 (0)" jid="test123@conference.103.73.190.162"/>
<item name="test12356789 (0)" jid="test12356789@conference.103.73.190.162"/>
<item name="test123567890121 (0)" jid="test123567890121@conference.103.73.190.162"/>
<item name="yahhobysyncinc (0)" jid="yahhobysyncinc@conference.103.73.190.162"/>
</query></iq>) */


