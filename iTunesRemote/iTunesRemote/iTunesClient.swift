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

// https://github.com/Alamofire/Alamofire/tree/swift-2.0#generic-response-object-serialization
extension Request {
    public func responseObject<T: Decodable where T == T.DecodedType>(completionHandler: (NSURLRequest?, NSHTTPURLResponse?, Result<T>) -> Void) -> Self {
        let responseSerializer = GenericResponseSerializer<T> { request, response, data in
            let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, data)
            
            switch result {
            case .Success(let value):
                let decoded: Decoded<T> = decode(value)
                switch decoded {
                case .Success(let object):
                    return .Success(object)
                case .MissingKey(let key):
                    return .Failure(data, Error.errorWithCode(.JSONSerializationFailed, failureReason: "Missing key \(key): \(value)"))
                case .TypeMismatch(let type):
                    return .Failure(data, Error.errorWithCode(.JSONSerializationFailed, failureReason: "Type mismatch for \(type): \(value)"))
                }
            case .Failure(let data, let error):
                return .Failure(data, error)
            }
        }
        
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
}

enum Router: URLRequestConvertible {
    static var server: Server!
    
    case GetArtist(String)
    
    case SetVolume(UInt)
    
    var method: Alamofire.Method {
        switch self {
        case .GetArtist:
            return .GET
        case .SetVolume:
            return .PUT
        }
    }
    
    var path: String {
        switch self {
        case .GetArtist(let name):
            return "/library/artist/\(name)"
        case .SetVolume:
            return "/control/volume"
        }
    }
    
    var URLRequest: NSMutableURLRequest {
        let URL = NSURL(string: Router.server.baseURL)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        mutableURLRequest.setValue(Router.server.authorizationHeader, forHTTPHeaderField: "Authorization")
        
        switch self {
        case .SetVolume(let volume):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: ["volume": volume]).0
        default:
            return mutableURLRequest
        }
    }
}

class iTunesClient {
    let manager: Alamofire.Manager
    let server: Server
    
    init(manager: Alamofire.Manager, server: Server) {
        self.manager = manager
        self.server = server
    }
    
    convenience init(server: Server) {
        let certs = ServerTrustPolicy.certificatesInBundle()
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "gandalf.local": ServerTrustPolicy.PinCertificates(
                certificates: certs,
                validateCertificateChain: true,
                validateHost: true
            )
        ]
        self.init(manager:
            Alamofire.Manager(
                configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
                serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)),
            server: server)
    }
    
    // TODO: ReactiveCocoa API (include error info as well)
    func artist(name: String, completionHandler: Result<Artist> -> Void) {
        Router.server = server
        self.manager.request(Router.GetArtist(name))
            .responseObject { (_, _, result: Result<Artist>) -> Void in
                completionHandler(result)
        }
    }
}