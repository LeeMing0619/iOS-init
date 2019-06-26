//
//  MessagesViewController.swift
//  Prayer
//
//  Created by Harri Westman on 7/15/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit
import SVProgressHUD
import Firebase

class MessagesViewController: BaseViewController {
    var chatItems = [FChatItem]()
    @IBOutlet weak var tblChatItems: UITableView!
    var waitingUser: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        needsToRefresh = true
        
        NSNotificationCenter.defaultCenter().addObserverForName(Constant.Notification.START_CHAT, object: nil, queue: nil) { (notification) in
            if let userId = notification.object as? String {
                if self.chatItems.count != 0 {
                    self.startChatWithUserId(userId)
                }
                else {
                    self.waitingUser = userId
                }
            }
        }
        
        tblChatItems.rowHeight = UITableViewAutomaticDimension
        tblChatItems.estimatedRowHeight = 300
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (needsToRefresh) {
            self.loadChatItems()
            self.needsToRefresh = false
        }
        self.tblChatItems.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "sid_selectuser" {
            let userController = segue.destinationViewController as? UsersViewController
            userController!.isMultiSelectable = false
            userController!.delegate = self
        }
    }
    
    func loadChatItems() {
        chatItems.removeAll()
        
        SVProgressHUD.show()
        FChatHelper.loadChatItems { (_items) in
            SVProgressHUD.dismiss()
            self.chatItems.appendContentsOf(_items)
            self.createChatObserver()
            
            self.tblChatItems.reloadData()
            if self.waitingUser != nil {
                self.startChatWithUserId(self.waitingUser!)
                self.waitingUser = nil
            }
        }
    }
    
    func createChatObserver() {
        let firebase = FIRDatabase.database().referenceWithPath(Constant.Firebase.Chat.PATH).child(FUser.currentId())
        firebase.removeAllObservers()
        firebase.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            let item = FChatItem(path: Constant.Firebase.Message.PATH, Subpath: FUser.currentId(), dictionary: snapshot.value as! Dictionary<NSObject, AnyObject>)
            if self.chatItems.contains(item) == false {
                self.chatItems.append(item)
                self.tblChatItems.reloadData()
            }
        })
    }
    
    func startChatWith(user: FUser) {
        for item in self.chatItems {
            if item.targetUserId == user.objectId() {
                openChatWith(item)
                return
            }
        }
        
        let chatItem = FChatHelper.createChatWith(user)
        openChatWith(chatItem)
    }
    
    func startChatWithUserId(userId: String) {
        if let user = Manager.sharedInstance.userWithId(userId) {
            self.startChatWith(user)
        }
    }
    
    func openChatWith(chatItem: FChatItem) {
        let controller = ChatViewController()
        controller.chatItem = chatItem
        self.tabBarController?.navigationController?.pushViewController(controller, animated: true)
    }
}

extension MessagesViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CHAT_CELL") as! ChatTableViewCell
        cell.selectionStyle = .None
        cell.accessoryType = .None
        cell.resetWithChatItem(chatItems[indexPath.row])
        return cell
    }
}

extension MessagesViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let chatItem = chatItems[indexPath.row]
        self.openChatWith(chatItem)
    }
}

extension MessagesViewController: UsersViewControllerDelegate {
    func userSelected(users: [FUser]?) {
        if users == nil || users!.count == 0 {
            return
        }
        
        startChatWith(users![0])
    }
}
