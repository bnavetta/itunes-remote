//
//  iTunesClient.swift
//  iTunesRemote
//
//  Created by Ben Navetta on 8/30/15.
//  Copyright © 2015 Ben Navetta. All rights reserved.
//

import Foundation

import Alamofire
import Argo

class iTunesClient {
    let manager: Alamofire.Manager
    
    init(manager: Alamofire.Manager) {
        self.manager = manager
    }
    
    convenience init() {
        self.init(manager: Alamofire.Manager.sharedInstance)
    }
}