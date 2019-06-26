//
//  SharePrayViewController.swift
//  Prayer
//
//  Created by Harri Westman on 7/20/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit
import SVProgressHUD
import Social
import DMActivityInstagram

class SharePrayViewController: UIViewController {
    var prayContent: String?
    var prayPicture: UIImage?
    var prayTag: String?
    
    var selectedCircle: FCircle? = nil
    var selectedIndexPath: NSIndexPath? = nil
    
    @IBOutlet weak var tblCircles: UITableView!
    
    @IBAction func onBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onPostRequest(sender: AnyObject) {
        SVProgressHUD.show()
        
        var circleName = "world"
        if self.selectedCircle != nil {
            circleName = self.selectedCircle!.objectId()
        }
        
        FPrayHelper.createPray("How are you", content: prayContent, picture: prayPicture, circle: circleName, tag: prayTag) { (error, pray) in
            if error == nil
            {
                SVProgressHUD.showSuccessWithStatus("You've posted your Pray")
                pray!.image = self.prayPicture
                NSNotificationCenter.defaultCenter().postNotificationName(Constant.Notification.PRAY_POSTED, object: pray)
            }
            else
            {
                SVProgressHUD.showErrorWithStatus("Failure Post, Try again later")
            }
            SVProgressHUD.dismissWithDelay(2.0)
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func onFacebook(sender: AnyObject) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
            let composer = SLComposeViewController(forServiceType: SLServiceTypeFacebook);
            if self.prayContent != nil {
                composer.setInitialText(self.prayContent)
            }
            
            if self.prayPicture != nil {
                composer.addImage(self.prayPicture)
            }
            self.presentViewController(composer, animated: true, completion: nil)
        }
        else {
            SVProgressHUD.showErrorWithStatus("Facebook is not activated within your device.")
        }
    }
    
    @IBAction func onTwitter(sender: AnyObject) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            let composer = SLComposeViewController(forServiceType: SLServiceTypeTwitter);
            if self.prayContent != nil {
                composer.setInitialText(self.prayContent)
            }
            
            if self.prayPicture != nil {
                composer.addImage(self.prayPicture)
            }
            self.presentViewController(composer, animated: true, completion: nil)
        }
        else {
            SVProgressHUD.showErrorWithStatus("Twitter is not activated within your device.")
        }
    }
    
    @IBAction func onMail(sender: AnyObject) {
        var activityItems = [AnyObject]()
        if self.prayContent != nil {
            activityItems.append(self.prayContent!)
        }
        if self.prayPicture != nil {
            activityItems.append(self.prayPicture!)
        }
        
        let composer = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        self.presentViewController(composer, animated: true, completion: nil)
    }
    
    @IBAction func onInstagram(sender: AnyObject) {
        let instagramURL = NSURL(string: "instagram://app")
        if UIApplication.sharedApplication().canOpenURL(instagramURL!) == false{
            SVProgressHUD.showErrorWithStatus("Instagram is not activated within your device.")
            return
        }
        
        let instagramActivity = DMActivityInstagram()
        var activityItems = [AnyObject]()
        if self.prayContent != nil {
            activityItems.append(self.prayContent!)
        }
        if self.prayPicture != nil {
            activityItems.append(self.prayPicture!)
        }
        
        let composer = UIActivityViewController(activityItems: activityItems, applicationActivities: [instagramActivity])
        self.presentViewController(composer, animated: true, completion: nil)
    }
}


extension SharePrayViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Manager.sharedInstance.circles!.count == 0 {
            return 0
        }
        
        return Manager.sharedInstance.circles!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CIRCLE_CELL") as! SharePrayToCell
        cell.selectionStyle = .None
        
        let circle = Manager.sharedInstance.circles![indexPath.row]
        cell.resetWithCircle(circle)
        
        if self.selectedIndexPath != nil && self.selectedIndexPath == indexPath {
            cell.accessoryType = .Checkmark
        }
        else
        {
            cell.accessoryType = .None
        }
        return cell
    }
}

extension SharePrayViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! SharePrayToCell
        if self.selectedIndexPath != nil && self.selectedIndexPath == indexPath {
            self.selectedCircle = nil
            self.selectedIndexPath = nil
            tableView.reloadData()
        }
        else {
            self.selectedIndexPath = indexPath
            self.selectedCircle = cell.circle!
            tableView.reloadData()
        }
    }
}