//
//  FChatItem.swift
//  Prayer
//
//  Created by Harri Westman on 8/2/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit

class FChatItem: FObject {    
    var targetUserId: String?  {
        get{
            return self[Constant.Firebase.Chat.TARGET_USER_ID] as? String
        }
        set{
            self[Constant.Firebase.Chat.TARGET_USER_ID] = newValue
        }
    }
    
    var targetUserName: String? {
        get{
            return self[Constant.Firebase.Chat.TARGET_USER_NAME] as? String
        }
        set{
            self[Constant.Firebase.Chat.TARGET_USER_NAME] = newValue
        }
    }
    
    var lastmessage: String? {
        get{
            return self[Constant.Firebase.Chat.LAST_MESSAGE] as? String
        }
        set{
            self[Constant.Firebase.Chat.LAST_MESSAGE] = newValue
        }
    }
    
    var targetUserimageUrl: String? {
        get{
            return self[Constant.Firebase.Chat.TARGET_USER_IMAGE_URL] as? String
        }
        set{
            self[Constant.Firebase.Chat.TARGET_USER_IMAGE_URL] = newValue
        }
    }
    
    var messages: [[String:String]]?
}