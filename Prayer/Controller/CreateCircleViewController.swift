//
//  CreateCircleViewController.swift
//  Prayer
//
//  Created by Harri Westman on 7/26/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit
import SVProgressHUD

class CreateCircleViewController: UIViewController {
   
    @IBOutlet weak var txtCircleName: UITextField!
    @IBOutlet weak var tblUsers: UITableView!

    var users = [FUser]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onBack(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onCreateCircle(sender: AnyObject) {
        guard txtCircleName.text != ""else {
            SVProgressHUD.showErrorWithStatus("Please input the Circle name")
            return
        }
        
        SVProgressHUD.show()
        FCircleHelper.createCircle(txtCircleName.text) { (error, circle) in
            if error == nil {
                SVProgressHUD.showSuccessWithStatus("Circle has been created succesfully")
                Manager.sharedInstance.circles!.append(circle!)
                for user: FUser in self.users {
                    FCircleHelper.addMemberToCircle(circle!, member: user)
                }
                NSNotificationCenter.defaultCenter().postNotificationName(Constant.Notification.CIRCLE_CREATED, object: circle)
            }
            else {
                SVProgressHUD.showErrorWithStatus("Failed to create the Circle")
            }
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let userViewController = segue.destinationViewController as! UsersViewController
        userViewController.delegate = self
    }
}

extension CreateCircleViewController: UsersViewControllerDelegate {
    func userSelected(users: [FUser]?) {
        self.users = users!
        self.tblUsers.reloadData()
    }
}

extension CreateCircleViewController: UITableViewDataSource {
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

extension CreateCircleViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
}