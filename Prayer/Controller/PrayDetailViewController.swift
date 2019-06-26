//
//  PrayDetailViewController.swift
//  Prayer
//
//  Created by Harri Westman on 8/12/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class PrayDetailViewController: BaseViewController {
    var pray: FPray! = nil
    
    @IBOutlet weak var imgUser: UIImageView!
    
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblPostedDate: UILabel!
    
    @IBOutlet weak var imgPray: UIImageView!
    @IBOutlet weak var txtContent: UITextView!
    
    @IBOutlet weak var lblLikes: UILabel!
    @IBOutlet weak var lblComments: UILabel!
    
    @IBOutlet weak var tblComments: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblComments.rowHeight = UITableViewAutomaticDimension
        tblComments.estimatedRowHeight = 300

        initFromPray()
    }
    
    func initFromPray() {
        guard self.pray != nil else {
            return
        }

        lblUsername.text = pray.username
        lblPostedDate.text = Global_Functions.stringSinceDateFor(pray![Constant.Firebase.CREATEDAT] as! NSTimeInterval)
        
        txtContent.text = pray.content
        txtContent.layoutIfNeeded()
        
        if self.pray!.likes != nil {
            lblLikes.text = String(self.pray!.likes!.count)
        }
        else {
            lblLikes.text = "0"
        }
        
        if self.pray!.comments != nil {
            lblComments.text = String(self.pray!.comments!.count)
        }
        else {
            lblComments.text = "0"
        }
        
        self.imgUser.image = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named:  "icon_user"), diameter: 40).avatarImage
        if let user = Manager.sharedInstance.userWithId(pray!.user!) {
            pray!.userImage = user.picture()
        }
        if pray.userImage != nil {
            UIImage.imageForImageURLString(pray.userImage!, completion: { (image, success) in
                self.imgUser.image = JSQMessagesAvatarImageFactory.avatarImageWithImage(image!, diameter: 40).avatarImage
            })
        }
        
        if pray!.image == nil {
            if pray!.picture != nil {
                UIImage.imageForImageURLString(pray!.picture!) {(image, success) in
                    if (image != nil)
                    {
                        self.imgPray.image = image
                        self.updateHeader(self.tblComments)
                    }
                }
            }
            else {
                self.imgPray.image = nil
                self.updateHeader(self.tblComments)
            }
        }
        else {
            self.imgPray.image = pray!.image
            self.updateHeader(self.tblComments)
        }
        
        self.tblComments.reloadData()
    }
    
    func updateHeader(tableView: UITableView!) {
        guard tableView != nil else {
            return
        }
        
        UIView.animateWithDuration(0.3) {
            tableView.beginUpdates()
            if let headerView = tableView.tableHeaderView {
                let height = headerView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
                var frame = headerView.frame
                frame.size.height = height
                headerView.frame = frame
                tableView.tableHeaderView = headerView
                headerView.setNeedsLayout()
                headerView.layoutIfNeeded()
            }
            tableView.endUpdates()
        }
    }
    
    @IBAction func onChat(sender: AnyObject) {
        guard self.pray != nil else {
            return
        }
        
        if let userId = pray.user {
            if userId == FUser.currentId() {
                return
            }
        }
        
        self.tabBarController?.selectedIndex = 1 //Select Message
        
        dispatch_after(100, dispatch_get_main_queue(), {
            NSNotificationCenter.defaultCenter().postNotificationName(Constant.Notification.START_CHAT, object: self.pray.user)
        })
    }
    
    @IBAction func onClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension PrayDetailViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pray!.comments?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: CommentCell = tableView.dequeueReusableCellWithIdentifier("COMMENT_CELL") as! CommentCell
        cell.resetWithComment(self.pray!.comments![indexPath.row] as! [String : String])
        return cell
    }
}

extension PrayDetailViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
