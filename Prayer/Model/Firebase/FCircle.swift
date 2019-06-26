//
//  FCircle.swift
//  Prayer
//
//  Created by Harri Westman on 7/26/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit

class FCircle: FObject {
    var name: String? {
        get{
            return self[Constant.Firebase.Circle.NAME] as? String
        }
        set{
            self[Constant.Firebase.Circle.NAME] = newValue
        }
    }
    
    var numberOfMembers: Int? {
        get{
            if self[Constant.Firebase.Circle.MEMBERS] == nil {
                return self[Constant.Firebase.Circle.NUMBER_OF_MEMBERS] as? Int
            }
            else {
               return self.memberIds!.count
            }
        }
        set{
            self[Constant.Firebase.Circle.NUMBER_OF_MEMBERS] = newValue
        }
    }
    
    var memberIds: [String]?{
        get{
            return self[Constant.Firebase.Circle.MEMBERS] as? [String]
        }
        set{
            self[Constant.Firebase.Circle.MEMBERS] = newValue
        }
    }
    
    var users: [FUser]? = [FUser]()
    func addMember (user: FUser?) -> Bool{
        if user == nil {
            return false
        }
        
        for _user in self.users!{
            if (_user.objectId() == user!.objectId())
            {
                return false;
            }
        }
        
        self.users!.append(user!)
        return true
    }
    
    func removeMember (user: FUser?) -> Bool {
        if user == nil {
            return false
        }
        
        var index = self.users!.indexOf(user!)
        if index != nil {
            self.users!.removeAtIndex(index!)
        }
        
        index = self.memberIds?.indexOf(user!.objectId())
        if index != nil {
            self.memberIds?.removeAtIndex(index!)
        }
        return true
    }
}
