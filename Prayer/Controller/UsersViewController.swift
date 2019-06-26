//
//  UsersViewController.swift
//  Prayer
//
//  Created by Harri Westman on 7/26/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit

protocol UsersViewControllerDelegate {
    func userSelected(users: [FUser]?)
}

class UsersViewController: UIViewController {
    
    var isMultiSelectable = true
    var delegate: UsersViewControllerDelegate? = nil
    var selectedUser = [FUser]()
    
    @IBOutlet weak var tblUsers: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        if Manager.sharedInstance.users.count == 0 {
            NSNotificationCenter.defaultCenter().addObserverForName(Constant.Notification.USERS_LOADED, object: nil, queue: nil, usingBlock: { (notification) in
                self.tblUsers.reloadData()
            })
        }
    }
    
    @IBAction func onBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onDone(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
        
        if selectedUser.count > 0 {
            self.delegate!.userSelected(self.selectedUser)
        }
        else {
            let alert = UIAlertController(title: "Warnning", message: "Select user first, please", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}

extension UsersViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Manager.sharedInstance.users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MEMBER_CELL") as! UserTableViewCell
        cell.selectionStyle = .None
        cell.resetWithuser(Manager.sharedInstance.users[indexPath.row])
        
        if selectedUser.contains(cell.user!) {
            cell.accessoryType = .Checkmark
        }
        else {
            cell.accessoryType = .None
        }
        
        return cell
    }
}

extension UsersViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! UserTableViewCell
        if self.isMultiSelectable {
            if cell.accessoryType == .Checkmark {
                cell.accessoryType = .None
                selectedUser.removeAtIndex(selectedUser.indexOf(cell.user!)!)
            }
            else {
                cell.accessoryType = .Checkmark
                selectedUser.append(cell.user!)
            }
        }
        else {
            selectedUser.removeAll()
            selectedUser.append(cell.user!)
            tableView.reloadData()
        }
    }
}
