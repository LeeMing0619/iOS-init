//
//  FChat.swift
//  Prayer
//
//  Created by Harri Westman on 7/21/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import Firebase

class FChatHelper {
    static let sharedInstance = FChatHelper()
    var chatItems = [FChatItem]()
    
    class func imageNameWithDate() -> String{
        let interval = NSDate().timeIntervalSince1970;
        let userId = FUser.currentId()
        return userId + "/chat/\(interval).jpg"
    }
    
    class func createChatWith(targetUser: FUser) -> FChatItem {
        let chatItem = FChatItem (path: Constant.Firebase.Chat.PATH , Subpath: FUser.currentId())
        chatItem[Constant.Firebase.OBJECTID] = FUser.currentId() + targetUser.objectId() // This is a message ID
        chatItem.targetUserId = targetUser.objectId()
        chatItem.targetUserName = targetUser.name()
        chatItem.targetUserimageUrl = targetUser.picture()
        chatItem.saveInBackground { (error: NSError?) in
            if error != nil {
                print("Start Chat Failed")
            }
        }
        
        sharedInstance.chatItems.append(chatItem)
        
        let targetChatItem = FChatItem (path: Constant.Firebase.Chat.PATH , Subpath: targetUser.objectId())
        targetChatItem[Constant.Firebase.OBJECTID] = FUser.currentId() + targetUser.objectId() // This is a message ID
        targetChatItem.targetUserId = FUser.currentId()
        targetChatItem.targetUserName = FUser.currentUser()!.name()
        targetChatItem.targetUserimageUrl = FUser.currentUser()!.picture()
        targetChatItem.saveInBackground { (error: NSError?) in
            if error != nil {
                print("Start Chat Failed")
            }
        }
        
        return chatItem
    }
    
    class func loadChatItems(completion: (([FChatItem])->Void)?) {
        let reference = FIRDatabase.database().referenceWithPath(Constant.Firebase.Chat.PATH).child(FUser.currentId())
        reference.observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
            var chatItems = [FChatItem]()
            if snapshot.exists() {
                let sorted = Global_Functions.sort(snapshot.value as! Dictionary<NSObject, AnyObject>)
                for dictionary in sorted {
                    let object = FChatItem(path: Constant.Firebase.Chat.PATH, Subpath: FUser.currentId(), dictionary: dictionary as! [NSObject : AnyObject])
                    if let user = Manager.sharedInstance.userWithId(object.targetUserId!) {
                        object.targetUserimageUrl = user.picture()
                    }
                    chatItems.append(object)
                }
            }
            
            if completion != nil {
                completion!(chatItems)
            }
        }
    }
    
    class func loadMessages(messageId: String, completion: (([FObject])->Void)?) {
        let reference = FIRDatabase.database().referenceWithPath(Constant.Firebase.Message.PATH).child(messageId)
        reference.observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
            var messages = [FObject]()
            if snapshot.exists() {
                let sorted = Global_Functions.sortReverse(snapshot.value as! Dictionary<NSObject, AnyObject>)
                for dictionary in sorted {
                    let object = FChatItem(path: Constant.Firebase.Message.PATH, Subpath: messageId, dictionary: dictionary as! [NSObject : AnyObject])
                    messages.append(object)
                }
            }
            
            if completion != nil {
                completion!(messages)
            }
        }

    }
    
    class func deleteMessages(messageId: String) {
        let reference = FIRDatabase.database().referenceWithPath(Constant.Firebase.Message.PATH).child(messageId)
        reference.removeAllObservers()
        reference.removeValue()
    }
}
