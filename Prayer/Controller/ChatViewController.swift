//
//  ChatViewController.swift
//  Prayer
//
//  Created by Harri Westman on 8/3/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase
import SVProgressHUD

class ChatViewController: JSQMessagesViewController {
    var chatItem: FChatItem? = nil
    
    var firebase: FIRDatabaseReference? = nil
    
    var loaded: Int = 0
    var loads = [AnyObject]()
    var loadIds = [String]()
    
    var messages = [FObject]()
    var jsqmessages = [JSQMessage]()
    
    var avatars = Dictionary<String, AnyObject>()
    var avatarIds = [String]()
    
    var bubbleImageOutgoing: JSQMessagesBubbleImage? = nil
    var bubbleImageIncoming: JSQMessagesBubbleImage? = nil
    var avatarImageBlank: JSQMessagesAvatarImage? = nil

    override internal var senderId: String! {
        get {
            return FUser.currentId()
        }
        set {
            
        }
    }
    
    override internal var senderDisplayName: String! {
        get {
            return FUser.name()
        }
        set {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        self.bubbleImageIncoming = bubbleFactory.incomingMessagesBubbleImageWithColor(Constant.UI.BUBBLE_INCOMING_COLOR)
        self.bubbleImageOutgoing = bubbleFactory.outgoingMessagesBubbleImageWithColor(Constant.UI.BUBBLE_OUTGOING_COLOR)
        
        self.avatarImageBlank = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named:  "icon_user"), diameter: 40)
        self.firebase = FIRDatabase.database().referenceWithPath(Constant.Firebase.Message.PATH).child(self.chatItem!.objectId())
        
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: #selector(self.onTrash))
        self.navigationItem.rightBarButtonItem = barButtonItem
        self.loadMessages()
    }
    
    func onTrash() {
        for message: FObject in self.messages {
            if message[Constant.Firebase.Message.TYPE] as! String == Constant.Firebase.Message.MessageType.IMAGE {
                let imagePath = message[Constant.Firebase.Message.IMAGE_PATH] as? String
                if imagePath != nil {
                    SVProgressHUD.show()
                    let reference = FIRStorage.storage().referenceForURL(Constant.Firebase.FIREBASE_STORAGE).child(imagePath!)
                    reference.deleteWithCompletion({ (error) in
                        SVProgressHUD.dismiss()
                        if error != nil {
                            print("Image deleted Successfully")
                        }
                        else {
                            print("Image delete Error")
                        }
                    })
                }
                UIImage.deleteImageWithName(message[Constant.Firebase.Message.IMAGE] as! String)
            }
        }
        
        FChatHelper.deleteMessages(self.chatItem!.objectId())
        self.messages.removeAll()
        self.jsqmessages.removeAll()
        self.collectionView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView.collectionViewLayout.springinessEnabled = false
    }
    
    func loadMessages() {
        self.automaticallyScrollsToMostRecentMessage = true
        FChatHelper.loadMessages(self.chatItem!.objectId()) { (_messages) in
            for message:FObject in _messages {
                self.loads.append(message)
                self.loadIds.append(message.objectId())
            }
            
            self.insertMessages()
            self.scrollToBottomAnimated(false)
            self.createMessageObservers()
        }
    }
    
    func insertMessages(){
        let maxVal = loads.count - loaded
        let minVal = max(maxVal-10, 0)
        
        for i in (minVal..<maxVal).reverse() {
            let message: FObject = loads[i] as! FObject
            self.insertMessage(message)
            loaded += 1
        }
        
        self.automaticallyScrollsToMostRecentMessage = false
        self.finishReceivingMessage()
        self.automaticallyScrollsToMostRecentMessage = true
        self.showLoadEarlierMessagesHeader = (loaded != self.loads.count)
    }
    
    func createMessageObservers() {
        firebase?.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            let message = FObject.objectWithPath(Constant.Firebase.Message.PATH, Subpath: self.chatItem!.objectId(), dictionary: snapshot.value as! Dictionary<NSObject, AnyObject>)
            if self.loadIds.contains(message.objectId()) == false {
                let incoming = self.addMessage(message)
                if incoming {
                    JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                }
                self.finishReceivingMessage()
            }
        })
    }
    
    func createJSQMessageWith (message: FObject) -> JSQMessage {
        let senderId = message[Constant.Firebase.Message.SENDER_ID] as! String
        let senderName = message[Constant.Firebase.Message.SENDER_NAME] as! String
        let date = NSDate(timeIntervalSince1970: message[Constant.Firebase.CREATEDAT] as! NSTimeInterval)
        let text = message[Constant.Firebase.Message.TEXT]
        let type = message[Constant.Firebase.Message.TYPE]
        let imageUrl = message[Constant.Firebase.Message.IMAGE]
        
        var jsqmessage: JSQMessage
        if type as! String == Constant.Firebase.Message.MessageType.IMAGE {
            let photoItem = JSQPhotoMediaItem(image: nil)
            photoItem.appliesMediaViewMaskAsOutgoing = self.outGoing(message)
            
            jsqmessage = JSQMessage(senderId: senderId, senderDisplayName: senderName, date: date, media: photoItem)
            UIImage.imageForImageURLString(imageUrl as! String, completion: { (image, success) in
                photoItem.image = image
                self.collectionView.reloadData()
            })
        }
        else {
            jsqmessage = JSQMessage(senderId: senderId, senderDisplayName:senderName, date: date, text: text as! String)
        }
        return jsqmessage
    }
    
    func insertMessage(message: FObject) -> Bool {
        let jsqmessage = createJSQMessageWith(message)
        
        self.messages.insert(message, atIndex: 0)
        self.jsqmessages.insert(jsqmessage, atIndex: 0)
        
        return self.incoming(message)
    }
    
    func addMessage(message: FObject) -> Bool {
        let jsqmessage = createJSQMessageWith(message)

        self.chatItem!.lastmessage = message[Constant.Firebase.Message.TEXT] as? String
        self.chatItem?.saveInBackground()
        
        self.messages.append(message)
        self.jsqmessages.append(jsqmessage)
        
        return self.incoming(message)
    }
    
    func messageSend(text: String?, image: UIImage? = nil) {
        let message: FObject = FObject.objectWithPath(Constant.Firebase.Message.PATH, Subpath: self.chatItem!.objectId())
        message[Constant.Firebase.Message.SENDER_ID] = FUser.currentId()
        message[Constant.Firebase.Message.SENDER_NAME] = FUser.currentUser()!.name()
        message[Constant.Firebase.Message.TEXT] = text;
        message[Constant.Firebase.Message.TYPE] = Constant.Firebase.Message.MessageType.TEXT
        
        if image != nil {
            SVProgressHUD.showProgress(0)
            let imagePath = FChatHelper.imageNameWithDate()
            let storageReference = FIRStorage.storage().referenceForURL(Constant.Firebase.FIREBASE_STORAGE).child(imagePath)
            let task:FIRStorageUploadTask = storageReference.putData(UIImageJPEGRepresentation(image!, 0.6)!, metadata: nil, completion: { (metadata, error) in
                SVProgressHUD.dismiss()
                
                if error == nil {
                    let link = metadata?.downloadURL()?.absoluteString
                    UIImage.saveImageWithName(link!, image: image!)
                    message[Constant.Firebase.Message.IMAGE_PATH] = imagePath
                    message[Constant.Firebase.Message.IMAGE] = link
                    message[Constant.Firebase.Message.TYPE] = Constant.Firebase.Message.MessageType.IMAGE
                    message.saveInBackground()
                }
                else {
                    SVProgressHUD.showErrorWithStatus("Sending Image Failed")
                }
            })
            task.observeStatus(.Progress, handler: { (snapshot) in
                if snapshot.progress!.completedUnitCount == snapshot.progress!.totalUnitCount {
                    task.removeAllObservers()
                    SVProgressHUD.dismiss()
                }
                SVProgressHUD.showProgress(Float(snapshot.progress!.completedUnitCount)/Float(snapshot.progress!.totalUnitCount))
            })
        }
        else {
            message.saveInBackground()
        }
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage()
    }
    
    func incoming(message: FObject) -> Bool {
        let senderId: String = message[Constant.Firebase.Message.SENDER_ID] as! String
        if senderId == FUser.currentId() {
            return false
        }
        return true
    }
    
    func outGoing(message: FObject) -> Bool {
        let senderId: String = message[Constant.Firebase.Message.SENDER_ID] as! String
        if senderId != FUser.currentId() {
            return false
        }
        return true
    }
}

extension ChatViewController {  //JSQMessagesViewController
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        self.messageSend(text)
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        //For Attach Image
        self.showImageSelectActionSheet(self)
    }
    
    func showImageSelectActionSheet(sender: AnyObject) {
        let alert = UIAlertController(title: "Choose Photo", message: nil, preferredStyle: .ActionSheet)
        
        let actionLibrary = UIAlertAction(title: "Photo Library", style: .Default) { (action) in
            self.showPickerWithSourceType(.PhotoLibrary)
        }
        alert.addAction(actionLibrary)
        
        let actionSavedAlbum = UIAlertAction(title: "Saved Photos Album", style: .Default) { (action) in
            self.showPickerWithSourceType(.SavedPhotosAlbum)
        }
        alert.addAction(actionSavedAlbum)
        
        let actionCamera = UIAlertAction(title: "Take a picture", style: .Default) { (action) in
            self.showPickerWithSourceType(.Camera)
        }
        alert.addAction(actionCamera)
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(actionCancel)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showPickerWithSourceType(sourceType: UIImagePickerControllerSourceType)
    {
        if UIImagePickerController.isSourceTypeAvailable( sourceType) == false {
            return
        }
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.messageSend(nil, image:  pickedImage.resizeToWidth(100))
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension ChatViewController { //JSQMessages CollectionView DataSource
    func loadAvatars(userId: String?) {
        guard (userId != nil) else {
            print("User ID should not be nil: ChatViewController");
            return
        }
        
        if let userImage = Manager.sharedInstance.imageForUser(userId!) {
            UIImage.imageForImageURLString(userImage, completion: { (image, success) in
                self.avatars[userId!] = JSQMessagesAvatarImageFactory.avatarImageWithImage(image!, diameter: 30)
                self.performSelector(#selector(self.delayReload), withObject: nil, afterDelay: 0.1)
            })
        }
    }
    
    func delayReload() {
        self.collectionView.reloadData()
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return jsqmessages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        if self.outGoing(messages[indexPath.item]) {
            return bubbleImageOutgoing
        }
        else {
            return bubbleImageIncoming
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.item]
        let userId = message[Constant.Firebase.Message.SENDER_ID] as! String
        
        if self.avatars[userId] == nil {
            self.loadAvatars(userId)
            return avatarImageBlank
        }
        else {
            return avatars[userId] as! JSQMessagesAvatarImage
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        if indexPath.item % 3 == 0 {
            let jsqmessage = jsqmessages[indexPath.item]
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(jsqmessage.date)
        }
        else {
            return nil
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        if self.incoming(self.messages[indexPath.item]) {
            let jsqmessage = self.jsqmessages[indexPath.item]
            
            if indexPath.item > 0 {
                let previous = self.jsqmessages[indexPath.item - 1]
                if previous.senderId == jsqmessage.senderId {
                    return nil
                }
            }
            return NSAttributedString(string: jsqmessage.senderDisplayName)
        }
        else {
            return nil
        }
    }
}

extension ChatViewController { //UICollectionView DataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.jsqmessages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var color = UIColor.blackColor()

        if self.outGoing(messages[indexPath.item]) {
            color = UIColor.blackColor()
        }
        
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        if cell.textView != nil {
            cell.textView.textColor = color
            cell.textView.linkTextAttributes = [NSForegroundColorAttributeName: color]
            return cell
        }
        return cell
    }
}

extension ChatViewController { //UICollectionView Delegate , For Copy, Edit, Delete
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        super.collectionView(collectionView, shouldShowMenuForItemAtIndexPath: indexPath)
        return false //Temporarily false
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        return false //Temporarily false
    }
    
    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
        //For now, Do nothing
    }
}

extension ChatViewController { //JSQMessages Collection View Follow layout delegate
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if self.incoming(messages[indexPath.item]) {
            if indexPath.item > 0 {
                let jsqmessage = jsqmessages[indexPath.item]
                let previous = jsqmessages[indexPath.item - 1]
                
                if previous.senderId == jsqmessage.senderId {
                    return 0
                }
            }
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        else {
            return 0
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        else {
            return 0
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if self.outGoing(messages[indexPath.item]) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        else {
            return 0
        }
    }
}

extension ChatViewController { // Respoinding to Collection View Tap Events
    override func collectionView(collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        self.insertMessages()
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, atIndexPath indexPath: NSIndexPath!) {
        let message = messages[indexPath.item]
        if self.incoming(message) {
            // Show Profile of the user
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
//        let message = self.messages[indexPath.item]
//        let jsqmessage = self.jsqmessages[indexPath.item]
//        
//          Here we can show the picture, play audio, show map, etc.
    }
}









