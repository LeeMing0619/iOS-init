//
//  FCircle.swift
//  Prayer
//
//  Created by Harri Westman on 7/21/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import Firebase

class FCircleHelper: FObject {
    static var current_circles = [AnyObject]()
    
    class func createCircle(name: String?, completion: ((error: NSError?, circle: FCircle?)->Void)?) {
        let circle = FCircle(path: Constant.Firebase.Circle.PATH, Subpath: nil)
        circle.name = name
        circle.numberOfMembers = Int(1)
        if circle.memberIds == nil {
            circle.memberIds = [String]()
        }
        circle.memberIds?.append(FUser.currentId())
        
        circle.saveInBackground { (error: NSError?) in
            if error == nil
            {
                completion!(error: error, circle: circle)
                updateCircleInfoForUser(FUser.currentUser()!, circle: circle)
            }
            else {
                completion!(error: nil, circle: nil)
            }
        }
    }
    
    class func addMemberToCircle(circle: FCircle, member: FUser)
    {
        let reference = circle.databaseReference()
        let ret = circle.addMember(member)
        if ret {
            if circle.memberIds == nil {
                circle.memberIds = [String]()
            }
            
            circle.memberIds!.append(member.objectId())
            circle.numberOfMembers = Int(circle.memberIds!.count)
            reference.updateChildValues([Constant.Firebase.Circle.MEMBERS: circle.memberIds!, Constant.Firebase.Circle.NUMBER_OF_MEMBERS:circle.numberOfMembers!]) { (error, reference) in
                if error != nil {
                    print("Add user to circle" + error!.description)
                }
            }
        }
        
        for user: FUser in circle.users! {
            updateCircleInfoForUser(user, circle: circle)
        }
    }
    
    class func updateCircleInfoForUser(user: FUser, circle: FCircle)
    {
        var circles: [String: AnyObject]? = user[Constant.Firebase.User.CIRCLES] as? [String: AnyObject]
        if circles == nil {
            circles = [String: AnyObject]()
        }
        
        var circleDict = [NSObject: AnyObject]()
        circleDict[Constant.Firebase.Circle.NAME] = circle.name
        circleDict[Constant.Firebase.Circle.NUMBER_OF_MEMBERS] = circle.numberOfMembers!
        circleDict[Constant.Firebase.OBJECTID] = circle.objectId()
        
        let reference: FIRDatabaseReference = user.databaseReference().child(Constant.Firebase.User.CIRCLES)
        reference.updateChildValues([circle.objectId(): circleDict]) { (error, reference) in
            if error != nil {
                print("Add circle to user"+error!.description)
            }
        }
    }
    
    class func loadCircleDetail(circle: FCircle, completion: (FCircle?->Void)?) {
        let reference = circle.databaseReference()
        reference.observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
            if snapshot.exists() {
                let circleRet = FCircle(path: circle.path, Subpath: circle.subpath, dictionary: snapshot.value as! [NSObject : AnyObject])
                if completion != nil {
                    completion!(circleRet)
                }
            }
            if completion != nil {
                completion!(nil)
            }
        }
    }
    
    class func leaveCircleFromUser(user: FUser, circle: FCircle) {
        var reference = circle.databaseReference()
        if circle.memberIds?.count > 1 {
            circle.removeMember(user)
            reference.updateChildValues([Constant.Firebase.Circle.MEMBERS: circle.memberIds!, Constant.Firebase.Circle.NUMBER_OF_MEMBERS:circle.numberOfMembers!]) { (error, reference) in
                if error != nil {
                    print("Remove user from circle:" + error!.description)
                }
            }
        }
        else {
            reference.removeValue()
        }
        
        reference = user.databaseReference().child(Constant.Firebase.User.CIRCLES).child(circle.objectId())
        reference.removeValueWithCompletionBlock { (error, reference) in
            if error != nil {
                print("Remove circle from user:" + error!.description)
            }
        }
        
        for user: FUser in circle.users! {
            updateCircleInfoForUser(user, circle: circle)
        }
    }
}

