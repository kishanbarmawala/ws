//
//  wsTests.swift
//  wsTests
//
//  Created by Sacha Durand Saint Omer on 13/11/15.
//  Copyright © 2015 s4cha. All rights reserved.
//

import Alamofire
@testable import ws
import XCTest
import Combine

class WSTests: XCTestCase {
    
    var ws: WS!
    var cancellables = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        // Create webservice with base URL
        ws = WS("http://jsonplaceholder.typicode.com")
        ws.logLevels = .debug
        ws.postParameterEncoding = JSONEncoding.default
        ws.showsNetworkActivityIndicator = false
    }
    
    func testJSON() {
        let exp = expectation(description: "")
        
        // use "call" to get back a json
        ws.get("/users").then { (_: WSJSON) in
            exp.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
//    func testModels() {
//        let exp = expectation(description: "")
//        latestUsers().then { users in
//            XCTAssertEqual(users.count, 10)
//
//            let u = users[0]
//            XCTAssertEqual(u.identifier, 1)
//            exp.fulfill()
//
//            print(users)
//        }
//        waitForExpectations(timeout: 10, handler: nil)
//    }
    
    func testResponse() {
        let exp = expectation(description: "")
        ws.getRequest("/users").fetch().then { (statusCode, _, _) in
            XCTAssertEqual(statusCode, 200)
            exp.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
//    func testMultipart() {
//        let exp = expectation(description: "")
//        let wsFileIO = WS("https://file.io")
//        wsFileIO.logLevels = .debug
//        wsFileIO.postParameterEncoding = JSONEncoding.default
//        wsFileIO.showsNetworkActivityIndicator = false
//
//        let imgPath = Bundle(for: type(of: self)).path(forResource: "1px", ofType: "jpg")
//        let img = UIImage(contentsOfFile: imgPath!)
//        let data = img!.jpegData(compressionQuality: 1.0)!
//
//        wsFileIO.postMultipart("", name: "file", data: data, fileName: "file", mimeType: "image/jpeg").then { _ in
//            exp.fulfill()
//
//        }.onError { _ in
//            XCTFail("Posting multipart Fails")
//        }
//        waitForExpectations(timeout: 10, handler: nil)
//    }
    
    // Here is typically how you would define an api endpoint.
    // aka latestUsers is a GET on /users and I should get back User objects
//    func latestUsers() -> WSCall<[User]> {
//        let test: WSCall<[User]> = ws.get("/users")
//
//        return test
//    }
    
    func testReceiveOnMainThreadWorks() {
        let thenExp = expectation(description: "thenExp")
        let thenExp2 = expectation(description: "thenExp2")
        let finallyExp = expectation(description: "finallyExp")
        
        let subject = PassthroughSubject<String, Error>()
        
        subject.then { data in
            XCTAssertFalse(Thread.isMainThread)
            thenExp.fulfill()
        }
        
        subject
            .receiveOnMainThread()
            .then { data in
                print(data)
                XCTAssert(Thread.isMainThread)
                thenExp2.fulfill()
            }
            .finally {
                finallyExp.fulfill()
            }
        DispatchQueue.global(qos: .background).async {
            subject.send("Hello")
        }
        
        waitForExpectations(timeout: 3, handler: nil)
    }
}