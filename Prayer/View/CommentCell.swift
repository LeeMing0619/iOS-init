//
//  PrayTableViewCell.swift
//  Prayer
//
//  Created by Harri Westman on 7/22/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class CommentCell: UITableViewCell {
    var comment: [String: String]! = nil
    
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var lblPostedDate: UILabel!
    
    func resetWithComment(_comment: [String: String]) {
        self.comment = _comment
        lblUsername.text = self.comment[Constant.Firebase.Comment.USER_NAME] ?? ""
        lblComment.text = comment[Constant.Firebase.Comment.COMMENT] ?? ""
        
        self.imgUser.image = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "icon_user"), diameter: 40).avatarImage
        let userId = comment[Constant.Firebase.Comment.USER_ID]
        if let user = Manager.sharedInstance.userWithId(userId!) {
            if let picture = user.picture() {
                UIImage.imageForImageURLString(picture) {(image, success) in
                    if (image != nil)
                    {
                        self.imgUser.image = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: 40).avatarImage
                    }
                }
            }
        }        
        self.contentView.layoutIfNeeded()
    }
}
