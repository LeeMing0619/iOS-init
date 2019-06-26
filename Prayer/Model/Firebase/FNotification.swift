//
//  FNotification.swift
//  Prayer
//
//  Created by Harri Westman on 8/1/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit

class FNotification: FObject {
    var type: String? {
        get{
            return self[Constant.Firebase.Notification.TYPE] as? String
        }
        set{
            self[Constant.Firebase.Notification.TYPE] = newValue
        }
    }
    
    var content: String? {
        get{
            return self[Constant.Firebase.Notification.CONTENT] as? String
        }
        set{
            self[Constant.Firebase.Notification.CONTENT] = newValue
        }
    }
    
    var senderName: String? {
        get{
            return self[Constant.Firebase.Notification.SENDER_NAME] as? String
        }
        set{
            self[Constant.Firebase.Notification.SENDER_NAME] = newValue
        }
    }
    
    var senderId: String? {
        get{
            return self[Constant.Firebase.Notification.SENDER_ID] as? String
        }
        set{
            self[Constant.Firebase.Notification.SENDER_ID] = newValue
        }
    }
    
    var prayId: String? {
        get{
            return self[Constant.Firebase.Notification.PRAYID] as? String
        }
        set{
            self[Constant.Firebase.Notification.PRAYID] = newValue
        }
    }

}
