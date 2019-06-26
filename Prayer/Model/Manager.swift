//
//  Manager.swift
//  Prayer
//
//  Created by Harri Westman on 7/15/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit
import SVProgressHUD
import Firebase

class Manager{
    static let sharedInstance = Manager()
    
    var myPrays = [FPray]()
    var users = [FUser]()
    var circles: [FCircle]? = nil
    var tags = [String]()
    
    var userAddress: String? = nil
    
    var userLoggedIn: Bool = false
    
    private init() {
    }
    
    func initConfiguration()
    {
        SVProgressHUD.setDefaultStyle(.Light)
        SVProgressHUD.setDefaultMaskType(.Black)
        SVProgressHUD.setMinimumDismissTimeInterval(2.0)
        
        NSNotificationCenter.defaultCenter().addObserverForName(Constant.Notification.SIGN_IN, object: nil, queue: nil) { (notification) in
            self.userSignedIn()
        }
        
        if FUser.currentUser() != nil {
            NSNotificationCenter.defaultCenter().postNotificationName(Constant.Notification.SIGN_IN, object: nil)
        }
    }
    
    func userSignedIn() {
        userLoggedIn = true
        
        if users.count == 0 {
            loadAllUsers { (error) in
                if error != nil {
                    return
                }
                else {
                    NSNotificationCenter.defaultCenter().postNotificationName(Constant.Notification.USERS_LOADED, object: self.users)
                }
            }
        }
        
        SVProgressHUD.show()
        loadCircles { (error) in
            SVProgressHUD.dismiss()
            if error != nil {
                return
            }
            else {
                NSNotificationCenter.defaultCenter().postNotificationName(Constant.Notification.CIRCLES_LOADED, object: self.users)
            }
        }
        
        if self.userAddress != nil {
            Manager.updateUserLocation(self.userAddress!)
        }
    }
    
    func loadTags(completion: (([String])->Void)?) {
        let reference = FIRDatabase.database().referenceWithPath(Constant.Firebase.Tag.PATH)
        
        reference.observeSingleEventOfType(FIRDataEventType.Value) { (snapshot: FIRDataSnapshot) in
            if snapshot.exists() {
                if completion != nil {
                    self.tags.removeAll()
                    self.tags.appendContentsOf(snapshot.value as! [String])
                    completion!(snapshot.value as! [String])
                }
            }
        }
    }
    
    func imageForUser(userId: String) -> String? {
        let user = userWithId(userId)
        if user != nil {
            return user?.picture()
        }
        return nil
    }
    
    func userWithId (userId: String) -> FUser?{
        if userId == FUser.currentId() {
            return FUser.currentUser()
        }

        for user: FUser in self.users {
            if user.objectId() == userId {
                return user
            }
        }
        
        return nil
    }
    
    func setUserPhoto (userId: String, imageLink: String){
        let user = self.userWithId(userId)
        if user != nil {
            user![Constant.Firebase.User.PICTURE] = imageLink
        }
    }
    
    func loadAllUsers(completion: ((NSError?)->Void)?){
        users.removeAll()
        
        let reference = FIRDatabase.database().referenceWithPath(Constant.Firebase.User.PATH)
        let query: FIRDatabaseQuery = reference.queryOrderedByChild(Constant.Firebase.User.NAME_LOWER)
        query.observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
            if snapshot.exists() {
                for dictionary in (snapshot.value as! Dictionary<NSObject, AnyObject>).values {
                    let object = FUser(path: Constant.Firebase.User.PATH, Subpath: nil, dictionary: dictionary as! [NSObject : AnyObject])
                    if object.objectId() != FUser.currentId() {
                        self.users.append(object)
                    }
                }
            }
            else {
                completion!(NSError(domain: "load user failed", code: 1, userInfo: nil))
                return
            }
            if completion != nil {
                completion!(nil)
            }
        }
    }
    
    func loadCircles(completion: (NSError?->Void)?)
    {
        if self.circles == nil {
            self.circles = [FCircle]()
        }
        else {
            self.circles?.removeAll()
        }
        
        let reference = FIRDatabase.database().referenceWithPath(Constant.Firebase.User.PATH).child(FUser.currentId()).child(Constant.Firebase.User.CIRCLES)
        let query: FIRDatabaseQuery = reference.queryOrderedByChild(Constant.Firebase.Circle.NAME)
        query.observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
            if snapshot.exists() {
                for dictionary in (snapshot.value as! Dictionary<NSObject, AnyObject>).values {
                    let object = FCircle(path: Constant.Firebase.Circle.PATH, Subpath: nil, dictionary: dictionary as! [NSObject : AnyObject])
                    self.circles?.append(object)
                }
            }
            else {
                completion!(NSError(domain: "load user failed", code: 1, userInfo: nil))
                return
            }
            if completion != nil {
                completion!(nil)
            }
        }
    }
    
    func attachCircle(inout circle: FCircle)
    {
        if self.circles!.contains(circle) {
            let index = self.circles!.indexOf(circle)
            self.circles!.removeAtIndex(index!)
            self.circles!.insert(circle, atIndex: index!)
            
            for user: FUser in self.users{
                for userId in circle.memberIds! {
                    if user.objectId() == userId {
                        circle.addMember(user)
                    }
                }
            }
        }
    }
    
    func removeCircle(circle: FCircle) {
        for _circle: FCircle in self.circles! {
            if _circle.isEqual(circle) {
                let index = self.circles!.indexOf(_circle)
                self.circles!.removeAtIndex(index!)
                break
            }
        }
    }
    
    class func addPray(pray: FPray)
    {
        if sharedInstance.myPrays.contains(pray) {
            return
        }
        sharedInstance.myPrays.append(pray)
    }
    
    class func addPrays(prays: [FPray])
    {
        for pray: FPray in prays {
            addPray(pray)
        }
    }
    
    class func releaseAllResources() {
        sharedInstance.myPrays.removeAll()
        sharedInstance.users.removeAll()
    }
    
    class func setReminder(date: NSDate) {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        let notification = UILocalNotification()
        notification.userInfo = nil
        notification.alertBody = "Please check your prayers."
        notification.alertAction = "Pray Time"
        notification.fireDate = date
        notification.repeatInterval = .Day  // Can be used to repeat the notification
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    class func setAddress(address: String) {
        Manager.sharedInstance.userAddress = address
        updateUserLocation(address)
    }
    
    class func updateUserLocation(address: String) {
        if FUser.currentUser() != nil {
            let user = FUser.currentUser()
            user!.address = address
            user!.saveInBackground({ (error) in
                if error != nil {
                    print("User address update failed")
                }
            })
        }
    }
}
