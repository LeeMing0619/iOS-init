//
//  CircleDetailViewController.swift
//  Prayer
//
//  Created by Harri Westman on 7/26/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit
import SVProgressHUD

class CircleDetailViewController: UIViewController {
    var users = [FUser]()
    var circle: FCircle? = nil

    @IBOutlet weak var tblUsers: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.users = circle!.users!
        if circle!.users!.count == 0 {
            SVProgressHUD.show()
            FCircleHelper.loadCircleDetail(self.circle!, completion: { (circleRet) in
                SVProgressHUD.dismiss()
                if circleRet != nil {
                    self.circle = circleRet
                    Manager.sharedInstance.attachCircle(&self.circle!)
                    self.users = self.circle!.users!
                    self.tblUsers.reloadData()
                }
            })
        }
    }
    
    @IBAction func onLeave(sender: AnyObject) {
        Manager.sharedInstance.removeCircle(self.circle!)
        FCircleHelper.leaveCircleFromUser(FUser.currentUser()!, circle: self.circle!)
        NSNotificationCenter.defaultCenter().postNotificationName(Constant.Notification.LEFT_CIRCLE, object: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let userViewController = segue.destinationViewController as! UsersViewController
        userViewController.delegate = self
    }
    
    func appendUsersToCurrentCircle(_users: [FUser])
    {
        for user: FUser in _users {
            if users.contains(user) {
                continue
            }
            FCircleHelper.addMemberToCircle(circle!, member: user)
        }
        
        self.users = circle!.users!
        tblUsers.reloadData()
    }
}

extension CircleDetailViewController: UsersViewControllerDelegate {
    func userSelected(users: [FUser]?) {
        if users == nil || users?.count == 0 {
            return
        }
        
        self.appendUsersToCurrentCircle(users!)
    }
}

extension CircleDetailViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MEMBER_CELL") as! UserTableViewCell
        cell.selectionStyle = .None
        cell.resetWithuser(users[indexPath.row])
        return cell
    }
}

extension CircleDetailViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
}