//
//  NotificationsViewController.swift
//  Prayer
//
//  Created by Harri Westman on 7/15/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit
import SVProgressHUD

class NotificationsViewController: BaseViewController {

    @IBOutlet weak var tblNotifications: UITableView!
    var notifications = [FNotification]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblNotifications.rowHeight = UITableViewAutomaticDimension
        tblNotifications.estimatedRowHeight = 300
        
        self.needsToRefresh = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.needsToRefresh {
            self.needsToRefresh = false
            loadNotifications()
        }
    }
    
    func loadNotifications() {
        self.notifications.removeAll()
        
        SVProgressHUD.show()
        FNotificationHelper.loadNotifications { (_notifications) in
            SVProgressHUD.dismiss()
            self.notifications.appendContentsOf(_notifications)
            self.tblNotifications.reloadData()
        }
    }
}

extension NotificationsViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notifications.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NOTIFICATION_CELL") as! NotificationTableViewCell
        cell.selectionStyle = .None
        cell.resetWithNotification(notifications[indexPath.row])
        return cell
    }
}

extension NotificationsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
