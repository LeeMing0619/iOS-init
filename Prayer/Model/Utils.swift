//
//  AppConfiguration.swift
//  Prayer
//
//  Created by Harri Westman on 7/15/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit

extension NSError {
    class func description(description: String, code: Int) -> NSError {
        let domain = NSBundle.mainBundle().bundleIdentifier
        let userInfo: [NSObject : AnyObject] = [NSLocalizedDescriptionKey: description]
        return NSError(domain: domain!, code: code, userInfo: userInfo)
    }
    
    func getDescription() -> String {
        return self.userInfo[NSLocalizedDescriptionKey as NSObject] as! String
    }
}
