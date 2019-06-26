//
//  RequestsViewController.swift
//  Prayer
//
//  Created by Harri Westman on 7/15/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit
import HTHorizontalSelectionList
import SVProgressHUD

class RequestsViewController: BaseViewController{
    enum SegmentType: Int {
        case CIRCLE = 0, WORLD
    }
    
    @IBOutlet weak var circleListContainer: UIView!
    @IBOutlet weak var searchBarContainer: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var circleList: HTHorizontalSelectionList!
    @IBOutlet weak var tblPrays: UITableView!
    
    var circlePrays = [FPray]()
    var worldPrays = [FPray]()
    var prays = [FPray]()
    
    var selectedCircle: FCircle? = nil
    var selectedType: Int? = SegmentType.CIRCLE.rawValue
    
    var circles = [FCircle]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        circleList.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        circleList.selectionIndicatorColor = Constant.UI.GLOBAL_TINT_COLOR
        circleList.setTitleColor(Constant.UI.GLOBAL_TINT_COLOR, forState: .Selected)
        circleList.dataSource = self
        circleList.delegate = self
        circleList.reloadData()
        
        tblPrays.rowHeight = UITableViewAutomaticDimension
        tblPrays.estimatedRowHeight = 600
        
        self.needsToRefresh = true

        NSNotificationCenter.defaultCenter().addObserverForName(Constant.Notification.CIRCLE_CREATED, object: nil, queue: nil) { (notification) in
            self.circles = Manager.sharedInstance.circles!
            self.circleList.reloadData()
            self.loadPrays()
        }

        NSNotificationCenter.defaultCenter().addObserverForName(Constant.Notification.CIRCLES_LOADED, object: nil, queue: nil) { (notification) in
            self.circles = Manager.sharedInstance.circles!
            self.circleList.reloadData()
            self.refreshPraysInCircles()
            self.circlePrays.removeAll()
            self.prays.removeAll()
            self.loadPrays()
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(Constant.Notification.LEFT_CIRCLE, object: nil, queue: nil) { (notification) in
            self.circles = Manager.sharedInstance.circles!
            self.circleList.reloadData()
            self.refreshPraysInCircles()
            self.loadPrays()
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(Constant.Notification.PRAY_POSTED, object: nil, queue: nil) { (notification) in
            let pray: FPray? = notification.object as? FPray
            if pray != nil {
                if pray?.circle == "world" {
                    self.worldPrays.append(pray!)
                }
                else {
                    self.circlePrays.append(pray!)
                }
            }
            Manager.addPray(pray!)
            self.loadPrays()
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(Constant.Notification.USER_UPDATED, object: nil, queue: nil) { (notification) in
            self.tblPrays.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.needsToRefresh {
            self.needsToRefresh = false
            loadPrays()
        }
        tblPrays.reloadData()
    }

    override func signOutNotificationReceived() {
        super.signOutNotificationReceived()
        tblPrays.reloadData()
    }
    
    @IBAction func onSegmentChanged(sender: UISegmentedControl) {
        self.segmentSelected(sender.selectedSegmentIndex)
    }
    
    func segmentSelected(index: Int) {
        self.selectedType = index
        if self.selectedType == SegmentType.CIRCLE.rawValue {
            self.circleListContainer.hidden = false
            self.searchBarContainer.hidden = true
            loadPrays()
        }
        else {
            self.circleListContainer.hidden = true
            self.searchBarContainer.hidden = false
            loadPrays()
            if searchBar.text != nil {
                self.searchBar(self.searchBar, textDidChange: self.searchBar.text!)
            }
        }
    }
    
    func loadPrays()
    {
        self.prays.removeAll()
        self.tblPrays.reloadData()
        if self.selectedType == SegmentType.CIRCLE.rawValue {
            if self.circles.count == 0 {
                return
            }
            
            if self.circlePrays.count > 0 {
                if self.selectedCircle == nil {
                    self.prays.appendContentsOf(self.circlePrays)
                }
                else {
                    for pray in self.circlePrays {
                        if pray.circle == self.selectedCircle!.objectId() {
                            self.prays.append(pray)
                        }
                    }
                }
                self.tblPrays.reloadData()
            }
            else {
                SVProgressHUD.show()
                FPrayHelper.loadPrayOfCircles(self.circles, completion: { (_prays) in
                    if _prays.count != 0 {
                        self.addCirclePrays(_prays)
                        self.loadPrays()
                    }
                    SVProgressHUD.dismissWithDelay(2.0)
                })
            }
        }
        else {
            if self.worldPrays.count > 0 {
                self.prays.appendContentsOf(self.worldPrays)
                self.tblPrays.reloadData()
            }
            else {
                SVProgressHUD.show()
                FPrayHelper.loadPrayOfWorld(10, completion: { (_prays) in
                    if _prays.count != 0 {
                        self.addWorldPrays(_prays)
                        self.loadPrays()
                    }
                    SVProgressHUD.dismissWithDelay(2.0)
                })
            }
        }
    }
    
    func addCirclePrays(prays: [FPray]) {
        for pray in prays {
            if self.circlePrays.contains(pray) == false {
                self.circlePrays.append(pray)
            }
        }
    }
    
    func addWorldPrays(prays: [FPray]) {
        for pray in prays {
            if self.worldPrays.contains(pray) == false {
                self.worldPrays.append(pray)
            }
        }
    }

    func refreshPraysInCircles() {
        for i in (0..<circlePrays.count).reverse() {
            let pray = circlePrays[i]
            var isInExistingCircle = false
            for circle in self.circles {
                if circle.objectId() == pray.circle {
                    isInExistingCircle = true
                    break
                }
            }
            
            if isInExistingCircle == false{
                circlePrays.removeAtIndex(i)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "sid_praydetail" {
            let detailController = segue.destinationViewController as! PrayDetailViewController
            let cell = sender as? PrayTableViewCell ?? nil
            if cell != nil {
                detailController.pray = cell!.prayForCell
            }
        }
    }
}

extension RequestsViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.prays.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PRAY_CELL") as! PrayTableViewCell
        cell.selectionStyle = .None
        cell.tableView = tableView
        cell.resetWithPray(prays[indexPath.row])
        return cell
    }
}

extension RequestsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }
}

extension RequestsViewController: HTHorizontalSelectionListDelegate{
    func selectionList(selectionList: HTHorizontalSelectionList, didSelectButtonWithIndex index: Int) {
        if index == 0 {
            self.selectedCircle = nil
        }
        else {
            self.selectedCircle = self.circles[index-1]
        }
        loadPrays()
    }
}

extension RequestsViewController: HTHorizontalSelectionListDataSource{
    func numberOfItemsInSelectionList(selectionList: HTHorizontalSelectionList) -> Int {
        return self.circles.count + 1
    }
    
    func selectionList(selectionList: HTHorizontalSelectionList, titleForItemWithIndex index: Int) -> String?
    {
        if index == 0 {
            return "All"
        }
        else {
            return self.circles[index-1].name
        }
    }
}

extension RequestsViewController: UISearchBarDelegate {
    func extractPraysWithKeyword(keyword: String!) -> [FPray]{
        if keyword == nil || keyword.characters.count == 0 {
            return self.worldPrays
        }
        
        var filteredPrays = [FPray]()
        for pray in self.worldPrays {
            if let name = pray.username {
                if name.containsString(keyword) {
                    filteredPrays.append(pray)
                }
            }
        }
        return filteredPrays
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.prays = extractPraysWithKeyword(searchText)
        self.tblPrays.reloadData()
    }
}

