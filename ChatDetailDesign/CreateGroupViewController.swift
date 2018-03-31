//
//  CreateGroupViewController.swift
//  ChatDetailDesign
//
//  Created by Dipang Shetn on 01/09/17.
//  Copyright © 2017 Dipang iOS. All rights reserved.
//

import UIKit
import XMPPFramework

class CreateGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate, UsergroupDelegat {

    var xmppHelper : XmppController!
    @IBOutlet weak var txtfGroupName: UITextField!
    @IBOutlet weak var tableViewContact: UITableView!
    
    var arryContact = ["1234567890", "1111111111","5555555555","9898098980", "6388855555"]
    
    var arryContactSelect = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        xmppHelper = getXmppHelper()
        xmppHelper.userGroupDelegat = self

        self.tableViewContact.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.txtfGroupName.delegate = self
        let button1 = UIButton.init(type: .custom)
        button1.setImage(#imageLiteral(resourceName: "sendmsg"), for: UIControlState.normal)
        button1.addTarget(self, action: #selector(createGroup), for: UIControlEvents.touchUpInside)
        button1.frame = CGRect(x: 0, y: 0, width: 20 , height: 20 )
        let barButton1 = UIBarButtonItem(customView: button1)
        self.navigationItem.rightBarButtonItem = barButton1
        
        let buttonCancel = UIButton.init(type: .custom)
        buttonCancel.setImage(#imageLiteral(resourceName: "sendmsg"), for: UIControlState.normal)
        buttonCancel.addTarget(self, action: #selector(CancelGroup), for: UIControlEvents.touchUpInside)
        buttonCancel.frame = CGRect(x: 0, y: 0, width: 20 , height: 20 )
        let barCancel = UIBarButtonItem(customView: buttonCancel)
        self.navigationItem.leftBarButtonItem = barCancel
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getXmppHelper () -> XmppController {
        let appDeleget = UIApplication.shared.delegate as! AppDelegate
        return appDeleget.xmppHelper
    }
    
    func createGroup()  {
        
        if txtfGroupName.text!.isEmpty {
            
            let alert = UIAlertController(title: "",
                                          message: "Please enter Group Name",
                                          preferredStyle: UIAlertControllerStyle.alert)
            
            let cancelAction = UIAlertAction(title: "OK",
                                             style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            //vc will be the view controller on which you will present your alert as you cannot use self because this method is static.
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        if arryContactSelect.count == 0 {
            
            let alert = UIAlertController(title: "",
                                          message: "Please choose user",
                                          preferredStyle: UIAlertControllerStyle.alert)
            
            let cancelAction = UIAlertAction(title: "OK",
                                             style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            //vc will be the view controller on which you will present your alert as you cannot use self because this method is static.
            self.present(alert, animated: true, completion: nil)

            
            
            return
        }
        
        if arryContactSelect.count < 2 {
            
            let alert = UIAlertController(title: "",
                                          message: "Group must have minimum 2 user",
                                          preferredStyle: UIAlertControllerStyle.alert)
            
            let cancelAction = UIAlertAction(title: "OK",
                                             style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            //vc will be the view controller on which you will present your alert as you cannot use self because this method is static.
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        self.xmppHelper.createRoom(groupName: txtfGroupName.text!,arrUser: arryContactSelect)
    }
    
    func CancelGroup()  {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.arryContact.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = self.arryContact[indexPath.row]
        cell.accessoryType = .none
        if self.arryContactSelect.contains(self.arryContact[indexPath.row]) {
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let value = self.arryContact[indexPath.row]
        
        if arryContactSelect.contains(value) {
            if let index = arryContactSelect.index(where: {$0 == value}){
                self.arryContactSelect.remove(at: index)
            }
        } else {
            self.arryContactSelect.append(value)
        }
        
        DispatchQueue.main.async {
            tableView.reloadData()
        }
    }
    
    func InviteUserToAdd(sender: XMPPRoom) {
        
        var strJoin = ""
        for str in arryContactSelect {
            strJoin = "\(strJoin) \(str)"
        }
        strJoin =  "\(strJoin)-\(txtfGroupName.text!)"
        strJoin = strJoin.trim()
        
        for str in arryContactSelect {
            print("Room USer -> \(str)")
            let roomJid = XMPPJID.init(string: "\(str)@\(constantVar.hostUrl)")
            //sender.editPrivileges([XMPPRoom.item(withAffiliation: "member", jid: roomJid)])
           // sender.editPrivileges([XMPPRoom.item(withRole: "participant", jid:roomJid)])
            sender.inviteUser(roomJid!, withMessage: strJoin)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
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
