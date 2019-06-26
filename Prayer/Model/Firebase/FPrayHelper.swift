//
//  FPray.swift
//  Prayer
//
//  Created by Harri Westman on 7/21/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import Firebase
import SVProgressHUD

class FPrayHelper {
    static let sharedInstance = FPrayHelper()
    
    var numberOfPrayPage: UInt
    var prays: [FPray]?
    
    private init() {
        numberOfPrayPage = 10
        prays = [FPray]()
    }
        
    class func imageNameWithDate() -> String{
        let interval = NSDate().timeIntervalSince1970;
        let userId = FUser.currentId()
        return userId + "/pray/\(interval).jpg"
    }
    
    class func createPray(title: String?, content: String?, picture: UIImage?, circle: String?, tag: String?, completion: ((error: NSError?, pray: FPray?)->Void)?) {
        let storage = FIRStorage.storage()
        let reference = storage.referenceForURL(Constant.Firebase.FIREBASE_STORAGE).child(imageNameWithDate())
        
        if (picture != nil)
        {
            let picData = UIImageJPEGRepresentation(picture!, 0.6)
            reference.putData(picData!, metadata: nil) { (metadata, error) in
                if error == nil {
                    let link = metadata?.downloadURL()!.absoluteString
                    createPray(title, content: content, pictureLink: link, circle: circle, tag: tag, completion: { (error, pray) in
                        completion!(error: error, pray: pray)
                    })
                }
            }
        }
        else {
            createPray(title, content: content, pictureLink: nil, circle: circle, tag: tag, completion: { (error, pray) in
                completion!(error: error, pray: pray)
            })
        }
    }
    
    class func createPray(title: String?, content: String?, pictureLink: String?, circle: String?, tag: String?, completion: ((error: NSError?, pray: FPray?)->Void)?) {
        let pray = FPray(path: Constant.Firebase.Pray.PATH, Subpath: nil)
        pray[Constant.Firebase.Pray.TITLE] = title
        pray[Constant.Firebase.Pray.CONTENT] = content
        pray[Constant.Firebase.Pray.PICTURE] = pictureLink
        pray[Constant.Firebase.Pray.POSTED_USER] = FUser.currentId()
        pray[Constant.Firebase.Pray.POSTED_USER_NAME] = FUser.currentUser()!.name()
        pray[Constant.Firebase.Pray.COMMENTS] = Int(0)
        pray[Constant.Firebase.Pray.LIKES] = Int(0)
        pray[Constant.Firebase.Pray.ANSWERED] = Int(0)
        
        if tag != nil {
            pray[Constant.Firebase.Pray.TAG] = tag
        }
        
        if circle != nil {
            pray[Constant.Firebase.Pray.POSTED_CIRCLE] = circle
        }
        
        pray.saveInBackground { (error: NSError?) in
            if error == nil
            {
                completion!(error: error, pray: pray)
            }
            else {
                completion!(error: nil, pray: nil)
            }
        }
    }
    
    class func loadMyPray(completion: (([FPray])->Void)?){
        let reference = FIRDatabase.database().referenceWithPath(Constant.Firebase.Pray.PATH)
        let userId = FUser.currentId()
        let query: FIRDatabaseQuery = reference.queryOrderedByChild(Constant.Firebase.Pray.POSTED_USER).queryEqualToValue(userId)
        query.observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
            var objects = [FPray]()
            if snapshot.exists() {
                let sorted = sort(snapshot.value as! Dictionary<NSObject, AnyObject>)
                for dictionary in sorted {
                    let object = FPray(path: Constant.Firebase.Pray.PATH, Subpath: nil, dictionary: dictionary as! [NSObject : AnyObject])
                    objects.append(object)
                }
            }
            else  {
                
            }
            if completion != nil {
                completion!(objects)
            }
        }
    }
    
    class func loadPrayOfCircle(circle: String?, completion: (([AnyObject])->Void)?){
        let reference = FIRDatabase.database().referenceWithPath(Constant.Firebase.Pray.PATH)
        let query: FIRDatabaseQuery = reference.queryEqualToValue(circle, childKey: Constant.Firebase.Pray.POSTED_CIRCLE)
        query.observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
            var objects = [AnyObject]()
            if snapshot.exists() {
                let sorted = sort(snapshot.value as! Dictionary<NSObject, AnyObject>)
                for dictionary in sorted {
                    let object = FPray(path: Constant.Firebase.Pray.PATH, Subpath: nil, dictionary: dictionary as! [NSObject : AnyObject])
                    objects.append(object)
                }
            }
            if completion != nil {
                completion!(objects)
            }
        }
    }
    
    class func loadPrayOfCircles(circles: [FCircle], completion: ([FPray]->Void)?){
        for circle: FCircle in circles {
            let reference = FIRDatabase.database().referenceWithPath(Constant.Firebase.Pray.PATH)
            let query: FIRDatabaseQuery = reference.queryOrderedByChild(Constant.Firebase.Pray.POSTED_CIRCLE).queryEqualToValue(circle.objectId())
            query.observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
                var objects = [FPray]()
                if snapshot.exists() {
                    let sorted = sort(snapshot.value as! Dictionary<NSObject, AnyObject>)
                    for dictionary in sorted {
                        let object = FPray(path: Constant.Firebase.Pray.PATH, Subpath: nil, dictionary: dictionary as! [NSObject : AnyObject])
                        objects.append(object)
                    }
                }
                if completion != nil {
                    completion!(objects)
                }
            }
        }
    }
    
    class func loadPrayOfWorld(pageIndex: UInt, completion: (([FPray])->Void)?){
        let reference = FIRDatabase.database().referenceWithPath(Constant.Firebase.Pray.PATH)
        let query = reference.queryOrderedByChild(Constant.Firebase.CREATEDAT).queryLimitedToLast(sharedInstance.numberOfPrayPage * pageIndex)
        //let query: FIRDatabaseQuery = reference.queryOrderedByChild(Constant.Firebase.Pray.POSTED_CIRCLE).queryEqualToValue("world")
        query.observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
            var objects = [FPray]()
            if snapshot.exists() {
                let sorted = sort(snapshot.value as! Dictionary<NSObject, AnyObject>)
                for dictionary in sorted {
                    let object = FPray(path: Constant.Firebase.Pray.PATH, Subpath: nil, dictionary: dictionary as! [NSObject : AnyObject])
                    objects.append(object)
                }
            }
            if completion != nil {
                completion!(objects)
            }
        }
    }
    
    class func sort(dictionary: [NSObject : AnyObject]) -> [AnyObject] {
        var array: [AnyObject] = Array(dictionary.values)
        array.sortInPlace({ (obj1, obj2) -> Bool in
            let dict1 = obj1 as! Dictionary<NSObject, AnyObject>
            let dict2 = obj2 as! Dictionary<NSObject, AnyObject>
            return Int(dict1[Constant.Firebase.CREATEDAT] as! NSNumber) > Int(dict2[Constant.Firebase.CREATEDAT] as! NSNumber)
        })
        return array
    }
    
    class func like(pray: FPray, userId: String, completion: (Bool->Void)?) {
        let reference = pray.databaseReference()
        if pray.likes == nil {
            pray.likes = [String]()
        }
        if pray.likes!.contains(userId) == false{
            pray.likes!.append(userId)
        }
        else {
            completion!(false)
            return
        }
        
        SVProgressHUD.show()
        reference.updateChildValues([Constant.Firebase.Pray.LIKES: pray.likes!]) { (error, reference) in
            if completion != nil {
                if error == nil {
                    completion!(true)
                    SVProgressHUD.showSuccessWithStatus("Done")
                }
                else {
                    completion!(false)
                    SVProgressHUD.showSuccessWithStatus("Error Occured")
                }
            }
            else {
                SVProgressHUD.dismiss()
            }
        }
    }
    
    class func comment(pray: FPray, userId: String?, username: String?, comment: String?, completion: (Bool->Void)?) {
        if userId == nil || username == nil {
            return
        }
        
        let reference = pray.databaseReference()
        if pray.comments == nil {
            pray.comments = [AnyObject]()
        }
        
        var commentItem = [String: String]()
        commentItem[Constant.Firebase.Comment.USER_ID] = userId!
        commentItem[Constant.Firebase.Comment.USER_NAME] = username!
        commentItem[Constant.Firebase.Comment.COMMENT] = comment!
        pray.comments!.append(commentItem)
        
        SVProgressHUD.show()
        reference.updateChildValues([Constant.Firebase.Pray.COMMENTS: pray.comments!]) { (error, reference) in
            if completion != nil {
                if error == nil {
                    completion!(true)
                    SVProgressHUD.showSuccessWithStatus("Done")
                }
                else {
                    completion!(false)
                    SVProgressHUD.showSuccessWithStatus("Done")
                }
            }
        }
    }
    
    class func answer(pray: FPray?, answered: Int, completion: (Bool->Void)?) {
        pray!.answered = answered
        SVProgressHUD.show()
        pray!.saveInBackground { (error) in
            if completion != nil {
                if error == nil {
                    completion!(true)
                    SVProgressHUD.showSuccessWithStatus("Done")
                }
                else {
                    completion!(false)
                    SVProgressHUD.showSuccessWithStatus("Failed")
                }
            }
            else {
                SVProgressHUD.showSuccessWithStatus("Done")
            }
        }
    }
}
