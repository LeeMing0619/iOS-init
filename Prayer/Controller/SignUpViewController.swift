//
//  SignUpViewController.swift
//  Prayer
//
//  Created by Harri Westman on 7/15/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit
import SVProgressHUD

class SignUpViewController: UIViewController {

    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func onSignUp(sender: AnyObject) {
        guard txtName.text != "" && txtEmail.text != "" && txtPassword.text != "" else {
            SVProgressHUD.showErrorWithStatus("Input your credential, please")
            return
        }
        
        SVProgressHUD.show()
        FUser.createUserWithEmail(txtEmail.text!, password: txtPassword.text!, name: txtName.text!, completion: { (user, error: NSError?) in
            if error == nil {
                self.showTabbar()
                FUser.updateCurrentUser(Constant.Firebase.LoginMethod.LOGIN_EMAIL)
                SVProgressHUD.showSuccessWithStatus("Welcome " + FUser.name()! + "!")
                SVProgressHUD.dismissWithDelay(2.0)

                NSNotificationCenter.defaultCenter().postNotificationName(Constant.Notification.SIGN_IN, object: nil)
            }
            else {
                SVProgressHUD.showErrorWithStatus(error!.localizedDescription)
            }
        })
    }
    
    func showTabbar() {
        let appDelegate: AppDelegate? = UIApplication.sharedApplication().delegate as? AppDelegate
        appDelegate!.showTabBar(true)
    }
}
