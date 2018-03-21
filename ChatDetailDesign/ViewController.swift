//
//  ViewController.swift
//  ChatDetailDesign
//
//  Created by Binita Modi on 14/08/17.
//  Copyright © 2017 SYNC Technologies. All rights reserved.
//

import UIKit
import Photos

protocol UserListFromSendMessage {
    
    func updateUserFromSendMessage()
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UpdateTableDelegat {

    @IBOutlet weak var imgShowImage: UIImageView!
    @IBOutlet weak var viewShowphoto: UIView!
    @IBOutlet weak var constrainstOfMessageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewMessage: UIView!
    @IBOutlet weak var bottomConstrainstOfmessageView: NSLayoutConstraint!
    @IBOutlet weak var tableViewMsg: UITableView!
    @IBOutlet weak var txtMsg: UITextView!
    
    var OnTouchMethod:(view : ViewController, obj : ChatMessage)?
    var isGroupChat : Bool = false
    var userid = ""
    var userName = ""
    let fromUserid = "9898098980"
    var arrayChatMessage = [ChatMessage]()
    var arrayChatMessageWithSection = [ChatMessageObject]()
    var xmppHelper : XmppController!
    let imagePicker = UIImagePickerController()
    var updateSendListDelegat : UserListFromSendMessage?
    var imageArray = [AnyObject]()
    var mutableArray = [AnyObject]()
    var arrayGroupUser = [String]()
        
    override func viewDidLoad() {
        
        super.viewDidLoad()
        print(userid)

        self.view.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "bg"))
        imagePicker.delegate = self
        self.viewShowphoto.isHidden = true
        self.tableViewMsg.dataSource = self
        self.tableViewMsg.delegate = self
        self.tableViewMsg.register(UINib(nibName: "sendTableViewCell", bundle: nil), forCellReuseIdentifier: "sendTableViewCell")
        self.tableViewMsg.register(UINib(nibName: "receiverTableViewCell", bundle: nil), forCellReuseIdentifier: "receiverTableViewCell")
        self.tableViewMsg.register(UINib(nibName: "sendImageTableViewCell", bundle: nil), forCellReuseIdentifier: "sendImageTableViewCell")
        self.tableViewMsg.register(UINib(nibName: "ReceiveImageTableViewCell", bundle: nil), forCellReuseIdentifier: "ReceiveImageTableViewCell")
        self.tableViewMsg.estimatedRowHeight = 180
        self.tableViewMsg.rowHeight = UITableViewAutomaticDimension
        self.tableViewMsg.tableFooterView = UIView()
        self.tableViewMsg.transform = CGAffineTransform(rotationAngle: -(CGFloat)(M_PI))
        self.tableViewMsg.keyboardDismissMode = .onDrag
        //self.txtMsg.becomeFirstResponder()
        
        self.txtMsg.layer.cornerRadius = 10
        self.txtMsg.clipsToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        print(DateUtlity.milliscondtoDate(millisecond: Date().millisecondsSince1970))
   
        xmppHelper = getXmppHelper()
        xmppHelper.deleget = self
        constantVar.chatMessageTime = Int(Date().millisecondsSince1970)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.getStoredMessage()
            self.sendUnSendMessage()
        }
        print("ISGroup -> \(isGroupChat)")
        
        if isGroupChat {
            arrayGroupUser = CoredataManager.fetchGroupUser(groupName: userName)
            print("group User -> \(arrayGroupUser)")
            //arrGroupUser =
        }
    }
    
    @IBAction func funCloseImageView(_ sender: Any) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.viewShowphoto.isHidden = true
        
    }
    func doThisWhenNotify() {
        print("I've sent a ViewController!")
    }
    
   func getXmppHelper () -> XmppController {
        
        let appDeleget = UIApplication.shared.delegate as! AppDelegate
        return appDeleget.xmppHelper
    }
    
    func sendUnSendMessage()  {
       let arrayMsg =  CoredataManager.fetchUnSendChatMassage()
        for chatObj in arrayMsg {
            self.xmppHelper.resendUnsendMessage(chatObj: chatObj)
        }
    }
    
    func getStoredMessage() {
        
        print("To user Id -> \(userid)")
        print("fromUserid user Id -> \(fromUserid)")
        
        var arrayLoadMessage = [ChatMessageObject]()
        let time = constantVar.chatMessageTime
        let array = CoredataManager.fetchChatMassage(time: time, toUser: userid, fromUser: fromUserid,isGroup: self.isGroupChat,groupName: self.userName)
        let arrayDate = CoredataManager.fetchChatMassageDate(time: time, toUser: userid, fromUser: fromUserid, isGroup: self.isGroupChat,groupName: self.userName)
        
        for item in arrayDate {
            let arrayFilter = array.filter({$0.date == item})
            if arrayFilter.count > 0 {
                let obj = ChatMessageObject()
                obj.date = item
                obj.arrChatMessage = arrayFilter
                arrayLoadMessage.append(obj)
            }
        }

        let date = arrayChatMessageWithSection.last?.date ?? ""
        let loadDate = arrayLoadMessage.first?.date ?? ""
        
        if date == loadDate && !(date.isEmpty) && !(loadDate.isEmpty) {
            
            let arr1 = (arrayChatMessageWithSection.last?.arrChatMessage)! as [ChatMessage]
            let arr2 = (arrayLoadMessage.first?.arrChatMessage)! as [ChatMessage]
            arrayChatMessageWithSection.last?.arrChatMessage?.removeAll()
            arrayChatMessageWithSection.last?.arrChatMessage?  = arr1 + arr2
            arrayLoadMessage.removeLast()
        }
        
        self.arrayChatMessageWithSection += arrayLoadMessage
        
        DispatchQueue.main.async {
            self.tableViewMsg.reloadData()
        }
    }

    @IBAction func sendPhoto(_ sender: Any) {
        self.clickImagePicker()
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        
        // self.clickImagePicker()
        
        let msg = txtMsg.text!.trim()
        txtMsg.text = ""
        txtMsg.frame.size.height = 30
        constrainstOfMessageViewHeight.constant = 40
        UIView.animate(withDuration: 0.0, animations: {
            self.viewMessage.layoutIfNeeded()
        })
        
        if !msg.isEmpty {
            let msg =  self.xmppHelper.sendMessage(toUser: userid, message: msg,fromUser: fromUserid,isGroup: self.isGroupChat,arrayUser: self.arrayGroupUser,groupName: userName)
            self.reloadTableWhenSend(chatObj: msg.0, date: msg.1)
            
            let userupdate = CoredataManager.updateUser(userno: msg.0.to!, username: msg.0.to!, message: msg.0.message!, type: msg.0.type!, date: msg.0.date!, time: msg.0.time!, isSender: msg.0.isSender!,isGroup: self.isGroupChat)
            
            if userupdate {
                updateSendListDelegat?.updateUserFromSendMessage()
            }
        }
    }
    
    func receiveChatMessage(chatObj: ChatMessage, date: String) {
        
        print("From -> \(chatObj.from)")
        if chatObj.from == userid {
            self.reloadTableWhenSend(chatObj: chatObj, date: date)
        } else {
            
        }
    }
    
    func reloadTableWhenSend(chatObj : ChatMessage, date : String) {
        
        if chatObj.id != nil {
            
            if date == self.arrayChatMessageWithSection.first?.date {
                self.arrayChatMessageWithSection.first?.arrChatMessage?.insert(chatObj, at: 0)
                self.tableViewMsg.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                self.tableViewMsg.reloadRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.automatic)
                
            } else {
                let obj = ChatMessageObject()
                obj.date = date
                obj.arrChatMessage = [chatObj]
                arrayChatMessageWithSection.insert(obj, at: 0)
                self.tableViewMsg.reloadData()
                // self.tableViewMsg.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
            }
            self.tableViewMsg.setContentOffset(.zero, animated: true)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.arrayChatMessageWithSection.count
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let obj = arrayChatMessageWithSection[section]
        return obj.date
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 4, width: tableView.frame.size.width, height: 20))
        view.backgroundColor = UIColor.clear
        let version = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 20))
        version.text = arrayChatMessageWithSection[section].date
        version.textAlignment = .center
        version.font = UIFont.systemFont(ofSize: 13)
        view.addSubview(version)
        view.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let obj = arrayChatMessageWithSection[indexPath.section].arrChatMessage?[indexPath.row]
        if obj?.isPhoto == true {
            return 210
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let obj = arrayChatMessageWithSection[section]
        if obj.arrChatMessage != nil {
            return (obj.arrChatMessage?.count)!
        }
        return 0
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let obj = (arrayChatMessageWithSection[indexPath.section].arrChatMessage?[indexPath.row])! as ChatMessage
        
        if obj.isPhoto == true {
            
            return cellForLoadPhoto(tableView: tableView, photoObj: obj)
            
        } else {
            
            return cellForLoadMessage(tableView: tableView, messageObj: obj)
        }
    }
    
    func cellForLoadPhoto(tableView: UITableView, photoObj : ChatMessage) -> UITableViewCell {
      
        if photoObj.isSender! {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiveImageTableViewCell") as! ReceiveImageTableViewCell
            cell.selectionStyle = .none
            cell.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
            cell.IBlblDate.text = DateUtlity.milliscondtoTime(millisecond: photoObj.time!)
            self.showFile(obj:photoObj, cell: cell)
            self.changePhotoStatusIcon(cell: cell, status: photoObj.status!)
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "sendImageTableViewCell") as! sendImageTableViewCell
            cell.selectionStyle = .none
            cell.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
            cell.IBlblDate.text = DateUtlity.milliscondtoTime(millisecond: photoObj.time!)
            self.showFile(obj:photoObj, cell: cell)
            return cell

        }

    }
    
    func cellForLoadMessage(tableView: UITableView, messageObj : ChatMessage) -> UITableViewCell {
    
        if messageObj.isSender! {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "receiverTableViewCell") as! receiverTableViewCell
            cell.selectionStyle = .none
            cell.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
            cell.txtvMsg.text = messageObj.message!
            cell.lblDate.text = DateUtlity.milliscondtoTime(millisecond: messageObj.time!)
            self.changeMessageStatusIcon(cell: cell, status: messageObj.status!)
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "sendTableViewCell") as! sendTableViewCell
            cell.selectionStyle = .none
            cell.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
            cell.txtvMsg.text = messageObj.message!
            cell.lblDate.text = DateUtlity.milliscondtoTime(millisecond: messageObj.time!)
            return cell
        }
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        
        let obj = (arrayChatMessageWithSection[indexPath.section].arrChatMessage?[indexPath.row])! as ChatMessage
        
        if obj.isPhoto == true {
            
            let dataDecoded : Data = Data(base64Encoded: (obj.photo?.photoUrl)!, options: .ignoreUnknownCharacters)!
            let image = UIImage(data: dataDecoded)
            DispatchQueue.main.async(execute: {
                
                UIView.animate(withDuration: 1.0, delay: 1.0, options: .transitionCrossDissolve, animations: {
                    
                    self.imgShowImage.image = image
                    
                }, completion: { (finished: Bool) in
                    
                    self.viewShowphoto.isHidden = false
                    self.navigationController?.setNavigationBarHidden(true, animated: true)
                    
                })
                
                
                
            })
        }
    }
    
    func keyboardWillShow(_ notification: Notification) {
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            bottomConstrainstOfmessageView.constant = keyboardRectangle.height
            
            UIView.animate(withDuration: 4.0, animations: {
                self.viewMessage.layoutIfNeeded()
            })
        }
    }
    
    func getUpdateTableCell(msgID: String, status: String) {
        
        for i in 0..<arrayChatMessageWithSection.count {
            
            let array = arrayChatMessageWithSection[i].arrChatMessage
                if let index = array?.index(where: {$0.id == msgID}) {
                
                let obj = (array?[index])! as ChatMessage
                obj.status! = status
                DispatchQueue.main.async {
                    self.tableViewMsg.beginUpdates()
                    self.tableViewMsg.reloadRows(at: [IndexPath(row: index, section: i)], with: UITableViewRowAnimation.automatic)
                    self.tableViewMsg.endUpdates()
                }
                break
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
           // self.getStoredMessage()
            self.perform(#selector(ViewController.getStoredMessage), with: nil, afterDelay: 0.1)
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
       
        bottomConstrainstOfmessageView.constant = 0
        viewMessage.needsUpdateConstraints()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.contentSize.height < 120 {
            var newFrame = textView.frame
            newFrame.size.height = textView.contentSize.height
            textView.frame = newFrame
            constrainstOfMessageViewHeight.constant = textView.frame.size.height + CGFloat(20.0)
            UIView.animate(withDuration: 0.0, animations: {
                self.viewMessage.layoutIfNeeded()
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Iamge Working module 
    func clickImagePicker() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
           // self.saveImage(image: pickedImage)
            
           self.perform(#selector(ViewController.saveImage(image:)), with: pickedImage, afterDelay: 0.1)
        }
        
         dismiss(animated: true, completion: nil)
        
        /*
         
         Swift Dictionary named “info”.
         We have to unpack it from there with a key asking for what media information we want.
         We just want the image, so that is what we ask for.  For reference, the available options are:
         
         UIImagePickerControllerMediaType
         UIImagePickerControllerOriginalImage
         UIImagePickerControllerEditedImage
         UIImagePickerControllerCropRect
         UIImagePickerControllerMediaURL
         UIImagePickerControllerReferenceURL
         UIImagePickerControllerMediaMetadata
         
         */
       
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func saveImage(image : UIImage) {
        
        //uploadFile.upload(img: pickedImage)
        
        let time = Int(Date().millisecondsSince1970)
        
        let thumbnailName = "\(time)thumb.png"
        let photoName = "\(time)photo.png"
        
        ChatImage.saveImageDocumentDirectory(ImageName: photoName, userId: userid, folderName: PhotoFolderType.Photo.rawValue, image: image)
        
        let imageResize = image.resizeImage(newWidth: 180)
        ChatImage.saveImageDocumentDirectory(ImageName: thumbnailName, userId: userid, folderName: PhotoFolderType.Thumbnail.rawValue, image: imageResize)
        
        let imageDataThumbnail: Data = UIImageJPEGRepresentation(imageResize, 0.1)!
        let thumbnail:String = imageDataThumbnail.base64EncodedString(options: .lineLength64Characters)
        
        let imageDataPhto: Data = UIImageJPEGRepresentation(image, 1.0)!
        let Photo:String = imageDataPhto.base64EncodedString(options: .lineLength64Characters)
        
        let msg = self.xmppHelper.getPhotoData(toUser: userid, fromUser:fromUserid , photoUrl: Photo, thumbnail: thumbnail, thumbnailName: thumbnailName, PhotoName: photoName,isGroup: self.isGroupChat)
        
        self.reloadTableWhenSend(chatObj: msg.0, date: msg.1)
        
        let userupdate = CoredataManager.updateUser(userno: msg.0.to!, username: msg.0.to!, message: msg.0.message!, type: msg.0.type!, date: msg.0.date!, time: msg.0.time!, isSender: msg.0.isSender!,isGroup: self.isGroupChat)
        
        if userupdate {
            
            updateSendListDelegat?.updateUserFromSendMessage()
        }
        
        let msgTemp = self.xmppHelper.sendPhoto(toUser: msg.0.to!, messageUrl: Photo, thumbImageData: thumbnail, thumbnaiFile: "", photoFile: "",msgId: msg.0.id!,millisecond: Double(msg.0.time!),isGroup: self.isGroupChat,arrayUser: self.arrayGroupUser,groupName: self.userName)
        
        print("MSg temp -> \(msgTemp.1)")
        //(toUser: "\(userid)@\(constantVar.hostUrl)", message: msg)
    }
    
    func showFile(obj : ChatMessage, cell : UITableViewCell)  {
        
        let dataDecoded : Data = Data(base64Encoded: (obj.photo?.thumbnail)!, options: .ignoreUnknownCharacters)!
        
         let image = UIImage(data: dataDecoded)
        
        if obj.isSender! {
            
            let cell = cell as! ReceiveImageTableViewCell
            
            DispatchQueue.main.async(execute: {
               cell.IBimageReceiver.image = image
            })
            
        } else {
            
            let cell = cell as! sendImageTableViewCell
            DispatchQueue.main.async(execute: {
                cell.IBimageSender.image = image
            })
        }
    }
    
    func  changeMessageStatusIcon (cell : receiverTableViewCell, status : String) {
        
        cell.IBImageMessageStatus.backgroundColor = UIColor.clear
        
        switch status {
        case MessageStatus.unsend.rawValue:
            cell.IBImageMessageStatus.image = UIImage(named: "unsend")
            
        case MessageStatus.send.rawValue:
            cell.IBImageMessageStatus.image = UIImage(named: "send")
            
        case MessageStatus.deliver.rawValue:
            cell.IBImageMessageStatus.image = UIImage(named: "deliver")
            
        case MessageStatus.read.rawValue:
            cell.IBImageMessageStatus.backgroundColor = UIColor.blue
            
        default:
            break
        }
    }
    
    func  changePhotoStatusIcon (cell : ReceiveImageTableViewCell, status : String) {
        
        cell.IBimgStatus.backgroundColor = UIColor.clear
        
        switch status {
        case MessageStatus.unsend.rawValue:
            cell.IBimgStatus.image = UIImage(named: "unsend")
            
        case MessageStatus.send.rawValue:
            cell.IBimgStatus.image = UIImage(named: "send")
            
        case MessageStatus.deliver.rawValue:
            cell.IBimgStatus.image = UIImage(named: "deliver")
            
        case MessageStatus.read.rawValue:
            cell.IBimgStatus.backgroundColor = UIColor.blue
            
        default:
            break
        }
    }

}

