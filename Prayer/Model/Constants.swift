//
//  AppConstants.swift
//  Prayer
//
//  Created by Harri Westman on 7/18/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit

struct Global_Functions {
    static func sort(dictionary: [NSObject : AnyObject]) -> [AnyObject] {
        var array: [AnyObject] = Array(dictionary.values)
        array.sortInPlace({ (obj1, obj2) -> Bool in
            let dict1 = obj1 as! Dictionary<NSObject, AnyObject>
            let dict2 = obj2 as! Dictionary<NSObject, AnyObject>
            return Double(dict1[Constant.Firebase.CREATEDAT]! as! NSNumber) > Double(dict2[Constant.Firebase.CREATEDAT] as! NSNumber)
        })
        return array
    }
    
    static func sortReverse(dictionary: [NSObject : AnyObject]) -> [AnyObject] {
        var array: [AnyObject] = Array(dictionary.values)
        array.sortInPlace({ (obj1, obj2) -> Bool in
            let dict1 = obj1 as! Dictionary<NSObject, AnyObject>
            let dict2 = obj2 as! Dictionary<NSObject, AnyObject>
            return Double(dict1[Constant.Firebase.CREATEDAT]! as! NSNumber) < Double(dict2[Constant.Firebase.CREATEDAT] as! NSNumber)
        })
        return array
    }
    
    static func stringSinceDateFor(interval: NSTimeInterval) -> String?{
        let period: Int = Int(NSDate().timeIntervalSince1970 - interval)
        
        let min = period/60
        let hours = (min/60)%24
        let day = (min/1440)
        let month = day / 30
        let year = month / 12
        
        var ret: String
        if (hours == 0)
        {
            ret = "\(min) min(s)"
        }
        else
        {
            ret = "\(hours) hr(s)"
            if (day > 0)
            {
                ret = "\(day%30) day(s)" + ret
                if (month > 0)
                {
                    ret = "\(month) month(s)"
                    if (year > 0)
                    {
                        ret = "\(year) yr(s) \(month%12) mth(s)"
                    }
                }
            }
        }
        return ret
    }
}

struct Constant{
    
    struct UI {
        static let GLOBAL_TINT_COLOR = UIColor(red: 208.0/255.0, green: 171.0/255.0, blue: 126.0/255.0, alpha: 1)
        
        static let BUBBLE_INCOMING_COLOR = UIColor(red: 230.0/255.0, green: 229.0/255.0, blue: 234.0/255.0, alpha: 1)
        static let BUBBLE_OUTGOING_COLOR = UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1)
    }
    
    struct StandardDefault {
        static let CURRENTUSER           = "CurrentUser"
    }
    
    struct Notification {
        static let SIGN_IN              = "NOTIFICATION_SIGN_IN"
        static let SIGN_OUT             = "NOTIFICATION_SIGN_OUT"
        static let USERS_LOADED         = "NOTIFICATION_USERS_LOADED"
        static let CIRCLES_LOADED       = "NOTIFICATION_CIRCLES_LOADED"
        static let CIRCLE_CREATED       = "NOTIFICATION_CIRCLE_CREATED"
        static let LEFT_CIRCLE          = "NOTIFICATION_LEFT_CIRCLE"
        static let START_CHAT           = "NOTIFICATION_START_CHAT"
        
        static let USER_UPDATED         = "NOTIFICATION_USER_UPDATED"
        static let PRAY_POSTED          = "NOTIFICATION_PRAY_POSTED"
        static let PRAY_UPDATED         = "NOTIFICATION_PRAY_UPDATED"
    }
    
    struct Firebase {
        
        static let authDomain           = "prayer-2872d.appspot.com"
        static let FIREBASE_STORAGE     = "gs://prayer-2872d.appspot.com"
        
        static let OBJECTID             = "objectId"			//	String
        static let CREATEDAT            = "createdAt"			//	String
        static let UPDATEDAT            = "updatedAt"			//	String
        
        struct User {
            static let PATH             = "User"				//	Path name
            static let EMAIL            = "email"				//	String
            static let NAME             = "name"				//	String
            static let NAME_LOWER       = "name_lower"			//	String
            static let ADDRESS          = "address"
            static let PHONENUMBER      = "phoneNumber"			//	String
            static let LOGINMETHOD      = "loginMethod"			//	String
            static let STATUS           = "status"				//	String
            
            static let PICTURE          = "picture"				//	String
            static let THUMBNAIL        = "thumbnail"			//	String
            static let CIRCLES          = "circles"             //  Array
        }
        
        struct Pray {
            static let PATH             = "Pray"
            static let TITLE            = "title"				//	String
            static let CONTENT          = "content"				//	String
            static let PICTURE          = "picture"				//	String
            static let TYPE             = "type"				//	String
            static let POSTED_USER      = "userId"
            static let POSTED_USER_NAME      = "userName"
            static let POSTED_USER_IMAGE     = "userImage"
            static let POSTED_CIRCLE    = "circleId"
            static let COMMENTS         = "comments"
            static let LIKES            = "likes"
            static let TAG              = "tag"
            static let ANSWERED         = "answered"
        }
        
        struct Circle {
            static let PATH             = "Circle"
            static let NAME             = "name"				//	String
            static let NUMBER_OF_MEMBERS          = "numberOfMembers"				//	Int
            static let MEMBERS          = "members"				//	Int
//            static let PICTURE          = "picture"				//	String
        }
        
        struct Comment {
            static let USER_ID          = "userId"
            static let USER_NAME        = "userName"
            static let COMMENT          = "comment"
        }
        
        struct Chat {
            static let PATH                     = "Chat"
            static let TARGET_USER_IMAGE_URL    = "image"
            static let TARGET_USER_ID           = "userId"
            static let TARGET_USER_NAME         = "userName"
            static let LAST_MESSAGE             = "lastMessage"
            static let MESSAGES                 = "messages"
        }
        
        struct Message {
            struct MessageType{
                static let TEXT                 = "text"
                static let IMAGE                = "image"
            }
            static let PATH              = "Message"
            static let SENDER_ID         = "senderId"
            static let SENDER_NAME       = "senderName"
            static let TEXT              = "text"
            static let TYPE              = "type"
            static let IMAGE             = "image"
            static let IMAGE_PATH        = "image_path"
        }
        
        struct Notification {
            static let PATH             = "Notification"
            struct Notification_Type {
                static let COMMENT         = "commented"
                static let LIKE            = "liked"
            }
            
            static let TYPE        = "type"
            static let CONTENT     = "content"
            static let SENDER_NAME = "sender_name"
            static let SENDER_ID   = "sender_Id"
            static let PRAYID      = "prayId"
        }
        
        struct LoginMethod {
            static let LOGIN_FACEBOOK	= "Facebook"
            static let LOGIN_EMAIL      = "Email"
        }
        
        struct Tag {
            static let PATH = "Tag"
        }
    }
}