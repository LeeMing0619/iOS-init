//
//  NotificationTableViewCell.swift
//  Prayer
//
//  Created by Harri Westman on 8/2/16.
//  Copyright © 2016 Jessup. All rights reserved.
//
import UIKit

class NotificationTableViewCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblContent: UILabel!
    
    var notification: FNotification?
    
    func resetWithNotification(_notification: FNotification?) {
        if _notification == nil {
            return
        }
        self.notification = _notification
        
        let title = NSMutableAttributedString(string: _notification!.senderName!, attributes: [NSForegroundColorAttributeName: Constant.UI.GLOBAL_TINT_COLOR, NSFontAttributeName: UIFont.systemFontOfSize(16)])
        
        if notification!.type == Constant.Firebase.Notification.Notification_Type.COMMENT {
            title.appendAttributedString(NSAttributedString(string: " commented on your request", attributes: [NSForegroundColorAttributeName: UIColor.darkGrayColor(), NSFontAttributeName: UIFont.systemFontOfSize(14)]))
        }
        else {
            title.appendAttributedString(NSAttributedString(string: " liked on your request", attributes: [NSForegroundColorAttributeName: UIColor.darkGrayColor(), NSFontAttributeName: UIFont.systemFontOfSize(14)]))
        }
        
        self.lblTitle.attributedText = title
        self.lblContent.text = _notification!.content
        
        self.contentView.layoutIfNeeded()
    }
}
