//
//  FPray.swift
//  Prayer
//
//  Created by Harri Westman on 7/21/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit
/*
 struct Pray {
 static let PATH             = "Pray"
 static let TITLE            = "title"				//	String
 static let CONTENT          = "content"				//	String
 static let PICTURE          = "picture"				//	String
 static let TYPE             = "type"				//	String
 static let POSTED_USER      = "userId"
 static let POSTED_CIRCLE    = "circleId"
 */

class FPray: FObject {
    var image: UIImage?
    
    var title: String? {
        get{
            return self[Constant.Firebase.Pray.TITLE] as? String
        }
        set{
            self[Constant.Firebase.Pray.TITLE] = newValue
        }
    }

    var content: String? {
        get{
            return self[Constant.Firebase.Pray.CONTENT] as? String
        }
        set{
            self[Constant.Firebase.Pray.TITLE] = newValue
        }
    }

    var type: String? {
        get{
            return self[Constant.Firebase.Pray.TYPE] as? String
        }
        set{
            self[Constant.Firebase.Pray.TYPE] = newValue
        }
    }
    
    var circle: String? {
        get{
            return self[Constant.Firebase.Pray.POSTED_CIRCLE] as? String
        }
        set{
            self[Constant.Firebase.Pray.POSTED_CIRCLE] = newValue
        }
    }
    
    var tag: String? {
        get{
            return self[Constant.Firebase.Pray.TAG] as? String
        }
        set{
            self[Constant.Firebase.Pray.TAG] = newValue
        }
    }

    var user: String? {
        get{
            return self[Constant.Firebase.Pray.POSTED_USER] as? String
        }
        set{
            self[Constant.Firebase.Pray.POSTED_USER] = newValue
        }
    }
    
    var picture: String? {
        get{
            return self[Constant.Firebase.Pray.PICTURE] as? String
        }
        set{
            self[Constant.Firebase.Pray.PICTURE] = newValue
        }
    }
    
    var username: String? {
        get{
            return self[Constant.Firebase.Pray.POSTED_USER_NAME] as? String
        }
        set{
            self[Constant.Firebase.Pray.POSTED_USER_NAME] = newValue
        }
    }
    
    var userImage: String? {
        get{
            return self[Constant.Firebase.Pray.POSTED_USER_IMAGE] as? String
        }
        set{
            self[Constant.Firebase.Pray.POSTED_USER_IMAGE] = newValue
        }
    }
    
    var comments: [AnyObject]? {
        get{
            return self[Constant.Firebase.Pray.COMMENTS] as? [AnyObject]
        }
        set{
            self[Constant.Firebase.Pray.COMMENTS] = newValue
        }
    }
    
    var likes: [String]? { // List of User Ids
        get{
            return self[Constant.Firebase.Pray.LIKES] as? [String]
        }
        set{
            self[Constant.Firebase.Pray.LIKES] = newValue
        }
    }
    
    var answered: Int? { // List of User Ids
        get{
            return self[Constant.Firebase.Pray.ANSWERED] as? Int
        }
        set{
            self[Constant.Firebase.Pray.ANSWERED] = newValue
        }
    }
}
