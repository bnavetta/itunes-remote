//
//  iTunesRemoteTests.swift
//  iTunesRemoteTests
//
//  Created by Ben Navetta on 8/28/15.
//  Copyright © 2015 Ben Navetta. All rights reserved.
//

import XCTest
@testable import iTunesRemote

//import Nimble
//import Quick
import Alamofire
import Argo

class iTunesRemoteTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let expectation = expectationWithDescription("Retrieve an artist")
        Alamofire.request(.GET, "http://gandalf:5000/library/artists/U2")
            .responseJSON { (_, _, json) -> Void in
                switch json {
                    case let .Success(json):
                        let u2: Artist = decode(json)!
                        XCTAssertEqual(u2.name, "U2")
                        debugPrint(u2)
                        XCTFail("Foo")
                    case let .Failure(_, error):
                        XCTFail("Error parsing JSON: \(error)")
                }
                
                expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10) { error in
            if let error =  error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
