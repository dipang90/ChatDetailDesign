//
//  xmppHelper.swift
//  CrazyMessages
//
//  Created by Binita Modi on 21/08/17.
//  Copyright © 2017 Erlang Solutions. All rights reserved.
//

import Foundation
import XMPPFramework
import Alamofire

struct constantVar {
    
    static let hostUrl = ""
    static let hostNumber = 5222
    static var chatMessageTime = 0
}

func sharedInstance() -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
}


struct uploadFile {
    static func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
   static func  upload(img : UIImage)  {
        
         let parameters = ["SenderRegistrationID":64 as AnyObject, "ReceiverMobileNumber":"1111111111" as AnyObject, "SenderMobileNumber":"5555555555" as AnyObject,"GalleryID":2 as AnyObject, "IsEpic":false as AnyObject ] as [String : AnyObject]
    
        let request = NSMutableURLRequest(url: URL(string: "")!)
        request.httpMethod = "POST"
        request.timeoutInterval = 1000
        let boundary = self.generateBoundaryString()
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            if let imgDataTemp = UIImageJPEGRepresentation(img, 0.5) {
                    let date =  Int (NSDate().timeIntervalSince1970)
                    multipartFormData.append(imgDataTemp, withName: "file_\(date)", fileName: "file_\(date).png", mimeType: "image/png")
            }
            
            let jsonData = try! JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.prettyPrinted)
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
            print("Json Data -> \(jsonString)")
            multipartFormData.append(jsonString.data(using: String.Encoding.utf8)!, withName: "emailContent")
            
        },with: request as URLRequest, encodingCompletion: { result in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (Progress) in
                    print("Upload Progress: \(Progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    if let JSON = response.result.value {
                        print("JSON: \(JSON)")
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        })
    }
}


