//
//  AppDelegate.swift
//  Prayer
//
//  Created by Harri Westman on 7/14/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var locationManager: CLLocationManager!
    var tabbarController: UITabBarController!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        FIRApp.configure()
        
        initNotificationSettings(application)
        
        let appearance = UITabBar.appearance()
        appearance.tintColor = Constant.UI.GLOBAL_TINT_COLOR
        
        let navAppearance = UINavigationBar.appearance()
        navAppearance.backgroundColor = Constant.UI.GLOBAL_TINT_COLOR
        navAppearance.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor(), NSFontAttributeName: UIFont.systemFontOfSize(16)]

        if FUser.currentUser() == nil{
            showWelcome()
        }
        else {
            showTabBar()
        }
        
        Manager.sharedInstance.initConfiguration()
        initGeolocation()
        
        return true
    }
    
    func initNotificationSettings(application: UIApplication) {
        var types: UIUserNotificationType = UIUserNotificationType()
        types.insert(UIUserNotificationType.Alert)
        types.insert(UIUserNotificationType.Badge)
        types.insert(UIUserNotificationType.Sound)
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: types, categories: nil))
    }
    
    func initGeolocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
//        let state = application.applicationState
//        if (state == .Active) {
//           SVProgressHUD.showInfoWithStatus("Prayer Time")
//        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

extension AppDelegate {
    enum LaunchViewController {
        case Welcome, TabBar
        
        var viewController: UIViewController
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            switch self {
            case .Welcome:
                return storyboard.instantiateViewControllerWithIdentifier("welcome");
            case .TabBar:
                return storyboard.instantiateViewControllerWithIdentifier("tabBar");
            }
        }
    }
    
    func showWelcome(animated: Bool = false)
    {
        (self.window?.rootViewController as? UINavigationController)?.popToRootViewControllerAnimated(animated)
    }
    
    func showTabBar(animated: Bool = false)
    {
        (self.window?.rootViewController as? UINavigationController)?.pushViewController(LaunchViewController.TabBar.viewController, animated: animated)
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        self.locationManager.stopUpdatingLocation()
        
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { (placeMarks, error) in
            if error == nil {
                let placeMark = placeMarks![0]
            
                //let street = placeMark.addressDictionary!["Street"] as? String ?? ""
                let state = placeMark.addressDictionary!["State"] as? String ?? ""
                let city = placeMark.addressDictionary!["City"] as? String ?? ""
                let country = placeMark.addressDictionary!["Country"] as? String ?? ""
                Manager.setAddress(city + ", " + state + ", " + country)
            }
        }
    }
}
