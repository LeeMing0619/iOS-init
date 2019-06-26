//
//  SignInViewController.swift
//  Prayer
//
//  Created by Harri Westman on 7/15/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit
import SVProgressHUD
import Firebase

class SignInViewController: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogIn(sender: AnyObject) {
        guard txtEmail.text != "" && txtPassword.text != "" else {
            SVProgressHUD.showErrorWithStatus("Input your credential, please")
            return
        }

        SVProgressHUD.show()
        FUser.signInWithEmail(txtEmail.text!, password: txtPassword.text!) { (user, error) in
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
        }
    }
    
    @IBAction func onForgotPassword(sender: AnyObject) {
        let alert = UIAlertController(title: "Reset Password", message: "Please input your email address.", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler(nil);
        let actionOk = UIAlertAction(title: "Ok", style: .Default, handler: { (action) in
            let textField = alert.textFields![0]
            let email = textField.text
            if email == nil {
                SVProgressHUD.showErrorWithStatus("Please type your email address")
            }
            else {
                SVProgressHUD.show()
                FIRAuth.auth()!.sendPasswordResetWithEmail(email!, completion: { (error) in
                    if error == nil {
                        SVProgressHUD.showSuccessWithStatus("Request sent to your email")
                    }
                    else {
                        SVProgressHUD.showErrorWithStatus(error!.userInfo[NSLocalizedDescriptionKey] as! String)
                    }
                })
            }
        })
        alert.addAction(actionOk)
        let actionCancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(actionCancel)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showTabbar() {
        let appDelegate: AppDelegate? = UIApplication.sharedApplication().delegate as? AppDelegate
        appDelegate!.showTabBar(true)
    }
}
