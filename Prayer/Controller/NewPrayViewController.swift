//
//  NewPrayViewController.swift
//  Prayer
//
//  Created by Harri Westman on 7/20/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit
import SVProgressHUD

class NewPrayViewController: UIViewController {
    @IBOutlet weak var imgPreview: UIImageView!
    @IBOutlet weak var txtContent: UITextView!
    
    var tags = [String]()
    var imagePickerController: UIImagePickerController?
    var selectedTag: String? = nil
    
    @IBAction func onClose(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onAddPhoto(sender: AnyObject) {
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
    
    @IBAction func onAddTags(sender: AnyObject) {
        if tags.count == 0 {
            Manager.sharedInstance.loadTags({ (_tags) in
                self.tags.appendContentsOf(_tags)
                self.showTagsList()
            })
        }
        else {
            self.showTagsList()
        }
    }
    
    func showTagsList(){
        guard self.tags.count != 0 else {
            SVProgressHUD.showErrorWithStatus("There are no tags selectable")
            return
        }
        
        let actionSheet = UIAlertController(title: "Tags", message: "Choose tag here", preferredStyle: .ActionSheet)
        for tag in self.tags {
            let action = UIAlertAction(title: tag, style: .Default, handler: { (action) in
                self.selectedTag = action.title
            })
            actionSheet.addAction(action)
        }
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
}

extension NewPrayViewController {
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tags.removeAll()
        self.tags.appendContentsOf(Manager.sharedInstance.tags)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let viewController = segue.destinationViewController as! SharePrayViewController
        
        viewController.prayContent = txtContent.text
        viewController.prayPicture = imgPreview.image
        viewController.prayTag = self.selectedTag
    }
}

extension NewPrayViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showPickerWithSourceType(sourceType: UIImagePickerControllerSourceType)
    {
        if UIImagePickerController.isSourceTypeAvailable( sourceType) == false {
            return
        }
        
        self.imagePickerController = UIImagePickerController()
        self.imagePickerController?.sourceType = sourceType
        imagePickerController!.delegate = self
        self.presentViewController(imagePickerController!, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imgPreview.image = pickedImage.resizeToWidth(200)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

