//
//  ChatTableViewCell.swift
//  Prayer
//
//  Created by Harri Westman on 8/2/16.
//  Copyright © 2016 Jessup. All rights reserved.
//
import UIKit
import JSQMessagesViewController

class ChatTableViewCell: UITableViewCell {
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    
    func resetWithChatItem (chat: FChatItem)
    {
        lblUserName.text = chat.targetUserName
        lblMessage.text = chat.lastmessage
        
        if chat.targetUserimageUrl != nil {
            UIImage.imageForImageURLString(chat.targetUserimageUrl!, completion: { (image, success) in
                self.imgUser.image = JSQMessagesAvatarImageFactory.avatarImageWithImage(image!, diameter: 40).avatarImage
            })
        }
        else {
            self.imgUser.image = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named:  "icon_user"), diameter: 40).avatarImage
        }
        self.contentView.layoutIfNeeded()
    }
}
