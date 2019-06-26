//
//  ReplaceSegue.swift
//  Prayer
//
//  Created by Harri Westman on 7/16/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit

class ReplaceSegue: UIStoryboardSegue {
    override func perform()
    {
        let navigationController = sourceViewController.navigationController
        let count: Int = (navigationController?.viewControllers.count)!
        
        if (count < 2)
        {
            navigationController?.pushViewController(destinationViewController, animated: true)
            return
        }
        
        let previousViewController = navigationController?.viewControllers[count - 2]
        if (previousViewController!.dynamicType == destinationViewController.dynamicType)
        {
            navigationController?.popViewControllerAnimated(true)
        }
        else {
            navigationController?.pushViewController(destinationViewController, animated: true)
        }
    }
}
