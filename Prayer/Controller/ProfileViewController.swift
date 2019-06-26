//
//  ProfileViewController.swift
//  Prayer
//
//  Created by Harri Westman on 7/15/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import SVProgressHUD
import Firebase

class ProfileViewController: BaseViewController {

    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var tblPrays: UITableView!

    @IBOutlet weak var btnRequests: UIButton!
    
    @IBOutlet weak var btnAnswered: UIButton!
    var showRequests: Bool = true
    
    var prays = [FPray]()
    var allPrays = [FPray]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblName.text = FUser.currentUser()!.name()
        self.lblAddress.text = FUser.currentUser()!.address ?? ""
        
        tblPrays.rowHeight = UITableViewAutomaticDimension
        tblPrays.estimatedRowHeight = 600

        if FUser.currentUser()!.picture() != nil {
            SVProgressHUD.show()
            UIImage.imageForImageURLString(FUser.currentUser()!.picture()!) { (image, success) in
                SVProgressHUD.dismiss()
                if success {
                    self.imgUser.image = JSQMessagesAvatarImageFactory.avatarImageWithImage(image!, diameter: 70).avatarImage
                }
                else {
                    self.imgUser.image = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "icon_user"), diameter: 70).avatarImage
                }
            }
        }
        else {
            self.imgUser.image = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "icon_user"), diameter: 70).avatarImage
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(Constant.Notification.PRAY_POSTED, object: nil, queue: nil) { (notification) in
            self.loadPray()
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(Constant.Notification.PRAY_UPDATED, object: nil, queue: nil) { (notification) in
            self.refreshPray()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadPray()
    }
    
    func loadPray() {
        if Manager.sharedInstance.myPrays.count == 0 {
            SVProgressHUD.show()
            FPrayHelper.loadMyPray { (_prays) in
                SVProgressHUD.dismiss()
                for pray: FPray in _prays {
                    Manager.addPray(pray)
                    self.allPrays.append(pray)
                }
                self.refreshPray()
            }
        }
        else {
            self.allPrays.removeAll()
            self.allPrays.appendContentsOf(Manager.sharedInstance.myPrays)
            self.tblPrays.reloadData()
            self.refreshPray()
        }
    }
    
    func refreshPray() {
        self.prays.removeAll()
        
        var answeredPrays = [FPray]()
        for pray in self.allPrays {
            if let answered = pray.answered {
                if answered == 1 {
                    answeredPrays.append(pray)
                }
            }
        }
        
        btnRequests.setTitle(String(self.allPrays.count), forState: .Normal)
        btnAnswered.setTitle(String(answeredPrays.count), forState: .Normal)
        
        if self.showRequests {
            self.prays.appendContentsOf(self.allPrays)
        }
        else {
            self.prays.appendContentsOf(answeredPrays)
        }
        self.tblPrays.reloadData()
    }
    
    func setUserPhoto(image: UIImage) {
        self.imgUser.image = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: 70).avatarImage
        SVProgressHUD.showProgress(0)
        let imagePath = FUser.imageNameWithDate()
        let storageReference = FIRStorage.storage().referenceForURL(Constant.Firebase.FIREBASE_STORAGE).child(imagePath)
        let task:FIRStorageUploadTask = storageReference.putData(UIImageJPEGRepresentation(image, 0.6)!, metadata: nil, completion: { (metadata, error) in
            SVProgressHUD.dismiss()
            if error == nil {
                let link = metadata?.downloadURL()?.absoluteString
                UIImage.saveImageWithName(link!, image: image)
                let user = FUser.currentUser()!
                user[Constant.Firebase.User.PICTURE] = link
                user.saveInBackground()
                Manager.sharedInstance.setUserPhoto(user.objectId(), imageLink: link!)
            }
            else {
                SVProgressHUD.showErrorWithStatus("Setting Image Failed")
            }
        })
        task.observeStatus(.Progress, handler: { (snapshot) in
            if snapshot.progress!.completedUnitCount == snapshot.progress!.totalUnitCount {
                task.removeAllObservers()
                SVProgressHUD.dismiss()
            }
            SVProgressHUD.showProgress(Float(snapshot.progress!.completedUnitCount)/Float(snapshot.progress!.totalUnitCount))
        })
        NSNotificationCenter.defaultCenter().postNotificationName(Constant.Notification.USER_UPDATED, object: nil)
    }
    
    @IBAction func onSignOut(sender: AnyObject) {
        if FUser.logOut() {
            let appDelegate: AppDelegate? = UIApplication.sharedApplication().delegate as? AppDelegate
            appDelegate!.showWelcome(true)
            
            Manager.releaseAllResources()
            NSNotificationCenter.defaultCenter().postNotificationName(Constant.Notification.SIGN_OUT, object: nil)
        }
    }

    @IBAction func onUserPhoto(sender: AnyObject) {
        self.showImageSelectActionSheet(self)
    }
    
    @IBAction func onReminder(sender: AnyObject) {
        DatePickerDialog().show("Set Reminder", doneButtonTitle: "Save", cancelButtonTitle: "Cancel", datePickerMode: UIDatePickerMode.Time) { (time) in
            if time != nil {
                Manager.setReminder(time!)
            }
        }
    }
    
    @IBAction func onRequests(sender: AnyObject) {
        self.showRequests = true
        refreshPray()
    }
    
    @IBAction func onAnswered(sender: AnyObject) {
        self.showRequests = false
        refreshPray()
    }
}

extension ProfileViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.prays.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: PrayInProfileTableViewCell = tableView.dequeueReusableCellWithIdentifier("PRAY_IN_PROFILE_CELL") as! PrayInProfileTableViewCell
        cell.resetWithPray(self.prays[indexPath.row])
        return cell
    }
}

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension ProfileViewController {
    
    func showImageSelectActionSheet(sender: AnyObject) {
        let alert = UIAlertController(title: "Choose Photo", message: nil, preferredStyle: .ActionSheet)
        
        let actionLibrary = UIAlertAction(title: "Photo Library", style: .Default) { (action) in
            self.showPickerWithSourceType(.PhotoLibrary)
        }
        alert.addAction(actionLibrary)
        
        let actionSavedAlbum = UIAlertAction(title: "Saved Photos Album", style: .Default) { (action) in
            self.showPickerWithSourceType(.SavedPhotosAlbum)
        }
        alert.addAction(actionSavedAlbum)
        
        let actionCamera = UIAlertAction(title: "Take a picture", style: .Default) { (action) in
            self.showPickerWithSourceType(.Camera)
        }
        alert.addAction(actionCamera)
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(actionCancel)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showPickerWithSourceType(sourceType: UIImagePickerControllerSourceType){
        if UIImagePickerController.isSourceTypeAvailable( sourceType) == false {
            return
        }
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.setUserPhoto(pickedImage.resizeToWidth(70))
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

