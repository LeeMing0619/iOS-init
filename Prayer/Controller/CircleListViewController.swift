//
//  CirclesViewController.swift
//  Prayer
//
//  Created by Harri Westman on 7/26/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit
import SVProgressHUD

class CircleListViewController: UIViewController {
    
    @IBOutlet weak var tblCircles: UITableView!
    var circles = [FCircle]()
    var selectedCircle: FCircle? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if Manager.sharedInstance.circles == nil {
            NSNotificationCenter.defaultCenter().addObserverForName(Constant.Notification.CIRCLES_LOADED, object: nil, queue: nil, usingBlock: { (notification) in
                self.showCircles()
            })
        }
        else {
            showCircles()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func showCircles() {
        self.circles = Manager.sharedInstance.circles!
        self.tblCircles.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "sid_showcircle" {
            let viewController: CircleDetailViewController = segue.destinationViewController as! CircleDetailViewController
            viewController.circle = self.selectedCircle
        }
    }
}

extension CircleListViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return circles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CIRCLE_CELL") as! CircleTableViewCell
        cell.selectionStyle = .None
        
        let circle = circles[indexPath.row]
        cell.resetWithCircle(circle)
        return cell
    }
}

extension CircleListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedCircle = circles[indexPath.row]
        self.performSegueWithIdentifier("sid_showcircle", sender: self)
    }
}
