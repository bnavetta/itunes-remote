//
//  Server.swift
//  iTunesRemote
//
//  Created by Ben Navetta on 8/30/15.
//  Copyright © 2015 Ben Navetta. All rights reserved.
//

import Foundation

struct Server {
    let baseURL: String
    let username: String
    let password: String
    // TODO: server certificate
    
    var authorizationHeader: String {
        let credentialData = "\(username):\(password)".dataUsingEncoding(NSUTF8StringEncoding)!
        let base64Credentials = credentialData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        return "Basic \(base64Credentials)"
    }
}

// TODO: code for interacting w/ keychain