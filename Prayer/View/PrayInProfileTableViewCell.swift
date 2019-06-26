//
//  PrayTableViewCell.swift
//  Prayer
//
//  Created by Harri Westman on 7/22/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class PrayInProfileTableViewCell: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var txtContent: UITextView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    
    @IBOutlet weak var lblLikes: UILabel!
    @IBOutlet weak var lblComments: UILabel!
    
    @IBOutlet weak var btnAnswer: UIButton!
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
        
        //Button Image change For Answer status
        btnAnswer.selected = false
        if let answered = pray!.answered {
            if answered == 1 {
                btnAnswer.selected = true
            }
        }
        //End
        
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
                            //self.tableView!.beginUpdates()
                            //self.tableView!.endUpdates()
                        }
                    }
                }
            }
            else {
                self.imgView.image = nil
                self.contentView.layoutIfNeeded()
                //self.tableView!.beginUpdates()
                //self.tableView!.endUpdates()
            }
        }
        else {
            self.imgView.image = pray!.image
            self.contentView.layoutIfNeeded()
            //self.tableView!.beginUpdates()
            //self.tableView!.endUpdates()
        }
    }

    @IBAction func onPrayAnswered(sender: AnyObject) {
        var isAnswered = false
        if let answered = self.prayForCell!.answered {
            if answered == 1 {
                isAnswered = true
            }
        }
        
        if isAnswered {
            FPrayHelper.answer(self.prayForCell, answered: 0, completion: { (result) in
                self.btnAnswer.selected = false
                NSNotificationCenter.defaultCenter().postNotificationName(Constant.Notification.PRAY_UPDATED, object: nil)
            })
        }
        else {
            FPrayHelper.answer(self.prayForCell, answered: 1, completion: { (result) in
                self.btnAnswer.selected = true
                NSNotificationCenter.defaultCenter().postNotificationName(Constant.Notification.PRAY_UPDATED, object: nil)
            })
        }
    }
}
