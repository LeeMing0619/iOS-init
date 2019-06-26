//
//  UIImage.swift
//  Prayer
//
//  Created by Harri Westman on 7/21/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import Foundation
import UIKit

public enum ImageFormat {
    case PNG
    case JPEG(CGFloat)
}

extension UIImage {
    static func imageForImageURLString(imageURLString: String, completion: (image: UIImage?, success: Bool) -> Void) {
        let userDefault = NSUserDefaults.standardUserDefaults()
        let data = userDefault.objectForKey(imageURLString) as? NSData
        if data != nil {
            completion(image: UIImage(data: data!), success: true)
            return
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            let url = NSURL(string: imageURLString)
            let data = NSData(contentsOfURL: url!)
            if (data == nil) {
                return
            }
            let image = UIImage(data: data!)
            if image != nil {
                userDefault.setObject(data, forKey: imageURLString)
                userDefault.synchronize()
                
                dispatch_async(dispatch_get_main_queue()) {
                    completion(image: image, success: true)
                }
            }
            else {
                completion(image: nil, success: false);
            }
        }
    }
    
    static func saveImageWithName (name: String, image: UIImage) {
        let userDefault = NSUserDefaults.standardUserDefaults()
        let data = UIImageJPEGRepresentation(image, 0.6)
        userDefault.setObject(data, forKey: name)
        userDefault.synchronize()
    }
    
    static func deleteImageWithName(image: String) {
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setObject(nil, forKey: image)
        userDefault.synchronize()
    }
    
    var uncompressedPNGData: NSData      { return UIImagePNGRepresentation(self)!        }
    var highestQualityJPEGNSData: NSData { return UIImageJPEGRepresentation(self, 1.0)!  }
    var highQualityJPEGNSData: NSData    { return UIImageJPEGRepresentation(self, 0.75)! }
    var mediumQualityJPEGNSData: NSData  { return UIImageJPEGRepresentation(self, 0.5)!  }
    var lowQualityJPEGNSData: NSData     { return UIImageJPEGRepresentation(self, 0.25)! }
    var lowestQualityJPEGNSData:NSData   { return UIImageJPEGRepresentation(self, 0.0)!  }
    
    func resize(scale:CGFloat)-> UIImage {        
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: size.width*scale, height: size.height*scale)))
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    func resizeToWidth(width:CGFloat)-> UIImage {
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    func resizeUnder(size: CGFloat)-> UIImage {
        var tempImg: UIImage?
        var tempImgSize: CGFloat = 0
        var scale: CGFloat = 1
        
        repeat {
            
            tempImg = resize(scale)
            
            tempImgSize = CGFloat(tempImg!.highestQualityJPEGNSData.length)
            scale = scale - 0.1
            
        }while tempImgSize > (1024 * 1024 * size)
        
        return tempImg!
    }
}
