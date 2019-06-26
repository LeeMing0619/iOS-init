//
//  FNotificationHelper.swift
//  Prayer
//
//  Created by Harri Westman on 8/1/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import Firebase
import SVProgressHUD

class FNotificationHelper {
    static let sharedInstance = FNotificationHelper()
    
    var notifications = [FNotification]()
    
    class func createNotification(toUserId: String?, senderName: String?, content: String?, type: String?, prayId: String?, completion: ((error: NSError?, notification: FNotification?)->Void)?) {
        let notification = FNotification(path: Constant.Firebase.Notification.PATH, Subpath: toUserId)
        
        notification[Constant.Firebase.Notification.SENDER_ID] = FUser.currentId()
        notification[Constant.Firebase.Notification.SENDER_NAME] = FUser.currentUser()!.name()!
        notification[Constant.Firebase.Notification.CONTENT] = content!
        notification[Constant.Firebase.Notification.TYPE] = type!
        notification[Constant.Firebase.Notification.PRAYID] = prayId!
        
        notification.saveInBackground { (error: NSError?) in
            if error == nil
            {
                completion!(error: error, notification: notification)
            }
            else {
                completion!(error: nil, notification: nil)
            }
        }
    }
    
    class func loadNotifications(completion: (([FNotification])->Void)?)
    {
        let userId = FUser.currentId()
        let reference = FIRDatabase.database().referenceWithPath(Constant.Firebase.Notification.PATH).child(userId)
        reference.observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
            var objects = [FNotification]()
            if snapshot.exists() {
                let sorted = Global_Functions.sort(snapshot.value as! Dictionary<NSObject, AnyObject>)
                for dictionary in sorted {
                    let object = FNotification(path: Constant.Firebase.Notification.PATH, Subpath: userId, dictionary: dictionary as! [NSObject : AnyObject])
                    objects.append(object)
                }
            }
            if completion != nil {
                completion!(objects)
            }
        }
    }
}

