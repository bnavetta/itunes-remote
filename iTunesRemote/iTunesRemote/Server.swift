//
//  Server.swift
//  iTunesRemote
//
//  Created by Ben Navetta on 8/30/15.
//  Copyright © 2015 Ben Navetta. All rights reserved.
//

import Foundation

import Alamofire

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

protocol CertificateStore {
    func getCertificate(host: String) -> SecCertificate?
    mutating func storeCertificate(host: String, certificate: SecCertificate)
    mutating func storeCertificate(host: String, certificateData: NSData)
    func createServerTrustPolicies() -> [String: ServerTrustPolicy]
}

class KeychainCertificateStore: CertificateStore {
    let valet = VALValet(identifier: "iTunesRemote.ServerCertificates", accessibility: .WhenUnlockedThisDeviceOnly)!
    
    func getCertificate(host: String) -> SecCertificate? {
        return valet.objectForKey(host).flatMap({ SecCertificateCreateWithData(nil, $0) })
    }
    
    func storeCertificate(host: String, certificate: SecCertificate) {
        valet.setObject(SecCertificateCopyData(certificate), forKey: host)
    }
    
    func storeCertificate(host: String, certificateData: NSData) {
        valet.setObject(certificateData, forKey: host)
    }
    
    func createServerTrustPolicies() -> [String: ServerTrustPolicy] {
        var policies = [String: ServerTrustPolicy]()
        for host in valet.allKeys() as! Set<String> {
            if let certificateData = valet.objectForKey(host), certificate = SecCertificateCreateWithData(nil, certificateData) {
               policies[host] = ServerTrustPolicy.PinCertificates(certificates: [certificate], validateCertificateChain: true, validateHost: true)
            }
            else {
                print("Warning: unable to load certificate for \(host)")
            }
        }
        return policies
    }
}