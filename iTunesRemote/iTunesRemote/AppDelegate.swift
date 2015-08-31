//
//  AppDelegate.swift
//  iTunesRemote
//
//  Created by Ben Navetta on 8/28/15.
//  Copyright © 2015 Ben Navetta. All rights reserved.
//

import UIKit

import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var manager: Alamofire.Manager?
    var client: iTunesClient?
    let server = Server(baseURL: "https://gandalf.local:5000", username: "ben", password: "avoid halo road")

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.backgroundColor = UIColor.whiteColor()
        window?.rootViewController = UIViewController(nibName: nil, bundle: nil)
        window?.makeKeyAndVisible()
        
        //        let label = UILabel()
        //        label.text = "Hello, World!"
        //        label.sizeToFit()
        //        window?.addSubview(label)
        
        let button = UIButton(type: UIButtonType.RoundedRect)
        button.setTitle("Click Me!", forState: .Normal)
        button.addTarget(self, action: "fireRequest", forControlEvents: .TouchUpInside)
        button.sizeToFit()
        
        window?.rootViewController = UIViewController()
        window?.rootViewController?.view.addSubview(button)
        
        print("Cache size: \(NSURLCache.sharedURLCache().currentDiskUsage)")
        
        
        let certs = ServerTrustPolicy.certificatesInBundle()
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "gandalf.local": ServerTrustPolicy.PinCertificates(
                certificates: certs,
                validateCertificateChain: true,
                validateHost: true
            )
        ]
        self.manager = Alamofire.Manager(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))

        self.client = iTunesClient(manager: self.manager!, server: server)
        
        return true
    }
    
    @objc
    func fireRequest() {
        client!.artist("U2") { (artist) -> Void in
            switch artist {
            case .Success(let artist):
                debugPrint(artist)
                break
            case .Failure(let data, let error):
                debugPrint(error)
                debugPrint(NSString(data: data!, encoding: NSUTF8StringEncoding))
                break
            }
        }
    
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

