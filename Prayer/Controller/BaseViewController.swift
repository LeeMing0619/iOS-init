//
//  BaseViewController.swift
//  Prayer
//
//  Created by Harri Westman on 7/22/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    var needsToRefresh: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserverForName(Constant.Notification.SIGN_OUT, object: nil, queue: nil) { (notification) in
            self.signOutNotificationReceived()
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(Constant.Notification.SIGN_IN, object: nil, queue: nil) { (notification) in
            self.signInNotificationReceived()
        }
    }
    
    func signInNotificationReceived()
    {
        needsToRefresh = true
    }
    
    func signOutNotificationReceived()
    {
        needsToRefresh = true
    }
}
