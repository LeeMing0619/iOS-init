//
//  PrayTableViewCell.swift
//  Prayer
//
//  Created by Harri Westman on 7/22/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class PrayTableViewCell: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var txtContent: UITextView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    
    @IBOutlet weak var lblLikes: UILabel!
    @IBOutlet weak var lblComments: UILabel!
    
    @IBOutlet weak var btnChat: UIButton!
    
    weak var prayForCell: FPray? = nil
    weak var tableView: UITableView?
    
    func resetWithPray(pray: FPray?) {
        if pray == nil {
            return
        }
        self.prayForCell = pray
        
        self.lblUsername.text = pray?.username
        self.lblDate.text = Global_Functions.stringSinceDateFor(pray![Constant.Firebase.CREATEDAT] as! NSTimeInterval)
            
        txtContent.text = pray!.content
        if self.prayForCell!.likes != nil {
            lblLikes.text = String(self.prayForCell!.likes!.count)
        }
        else {
            lblLikes.text = "0"
        }
        
        if self.prayForCell!.comments != nil {
            lblComments.text = String(self.prayForCell!.comments!.count)
        }
        else {
            lblComments.text = "0"
        }
        
        if self.prayForCell?.user != FUser.currentId() {
            btnChat.enabled = true
        }
        else {
            btnChat.enabled = false
        }

        if let user = Manager.sharedInstance.userWithId(pray!.user!) {
            pray!.userImage = user.picture()
        }
 
        if pray!.userImage != nil {
            UIImage.imageForImageURLString(pray!.userImage!) {(image, success) in
                if (image != nil)
                {
                    self.imgUser.image = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: 40).avatarImage
                }
                else {
                    self.imgUser.image = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "icon_user"), diameter: 40).avatarImage
                }
            }
        }
        else {
            self.imgUser.image = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "icon_user"), diameter: 40).avatarImage
        }
        
        if pray!.image == nil {
            if pray!.picture != nil {
                UIImage.imageForImageURLString(pray!.picture!) {(image, success) in
                    if (image != nil)
                    {
                        self.imgView.image = image
                        pray!.image = image
                        
                        if self.tableView != nil {
                            self.contentView.layoutIfNeeded()
                        }
                    }
                }
            }
            else {
                self.imgView.image = nil
                self.contentView.layoutIfNeeded()
            }
        }
        else {
            self.imgView.image = pray!.image
            self.contentView.layoutIfNeeded()
        }
    }
    
    @IBAction func onLike(sender: AnyObject) {
        if prayForCell!.likes != nil {
            if prayForCell!.likes!.contains(FUser.currentId()) == true {
                return
            }
        }
        
        let controller: RequestsViewController? = tableView!.delegate as? RequestsViewController
        if controller != nil {
            let alert: UIAlertController = UIAlertController(title: "Would you like to like this Pray?", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            let actionOk = UIAlertAction(title: "Ok", style: .Default, handler: { (action) in
                FPrayHelper.like(self.prayForCell!, userId: FUser.currentId(), completion: { (result) in
                    self.lblLikes.text = String(self.prayForCell!.likes!.count)
                })
                
                FNotificationHelper.createNotification(self.prayForCell!.user, senderName: self.prayForCell!.username, content: self.prayForCell!.content, type: Constant.Firebase.Notification.Notification_Type.LIKE, prayId: self.prayForCell!.objectId(), completion: { (error, notification) in
                    FNotificationHelper.sharedInstance.notifications.append(notification!)
                })
            })
            alert.addAction(actionOk)
            let actionCancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alert.addAction(actionCancel)
            controller?.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onComment(sender: AnyObject) {
        let controller: RequestsViewController? = tableView!.delegate as? RequestsViewController
        if controller != nil {
            let alert: UIAlertController = UIAlertController(title: "Type the comment", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addTextFieldWithConfigurationHandler(nil)
            let actionOk = UIAlertAction(title: "Ok", style: .Default, handler: { (action) in
                let textField = alert.textFields![0]
                
                FPrayHelper.comment(self.prayForCell!, userId: FUser.currentId(), username: self.prayForCell?.username, comment: textField.text!, completion: { (result) in
                    self.lblComments.text = String(self.prayForCell!.comments!.count)
                })
                
                FNotificationHelper.createNotification(self.prayForCell!.user, senderName: self.prayForCell!.username, content: textField.text!, type: Constant.Firebase.Notification.Notification_Type.COMMENT, prayId: self.prayForCell!.objectId(), completion: { (error, notification) in
                    FNotificationHelper.sharedInstance.notifications.append(notification!)
                })
            })
            alert.addAction(actionOk)
            let actionCancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alert.addAction(actionCancel)
            controller?.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onChat(sender: AnyObject) {
        let controller = tableView?.delegate as? RequestsViewController
        if controller != nil{
            controller?.tabBarController?.selectedIndex = 1 //Select Message
        }
        
        if self.prayForCell!.user != FUser.currentId() {
            dispatch_after(100, dispatch_get_main_queue(), {
                NSNotificationCenter.defaultCenter().postNotificationName(Constant.Notification.START_CHAT, object: self.prayForCell?.user)
            })
        }
    }
}
