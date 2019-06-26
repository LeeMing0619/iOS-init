//
//  UserTableViewCell.swift
//  Prayer
//
//  Created by Harri Westman on 7/28/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class UserTableViewCell: UITableViewCell {
    var user: FUser? = nil
    
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func resetWithuser (user: FUser)
    {
        self.user = user
        lblUserName.text = user.name()
        lblLocation.text = user.address ?? "N/A"
        if user.picture() != nil {
            UIImage.imageForImageURLString(user.picture()!, completion: { (image, success) in
                self.imgUser.image = JSQMessagesAvatarImageFactory.avatarImageWithImage(image!, diameter: 40).avatarImage
            })
        }
        else {
            self.imgUser.image = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named:  "icon_user"), diameter: 40).avatarImage
        }
    }
}
