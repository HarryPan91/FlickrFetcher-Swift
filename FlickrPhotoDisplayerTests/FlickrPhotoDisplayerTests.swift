//
//  FlickrPhotoDisplayerTests.swift
//  FlickrPhotoDisplayerTests
//
//  Created by Harry on 2/12/2015.
//  Copyright © 2015 Snaptee. All rights reserved.
//

import XCTest
import OHHTTPStubs
@testable import FlickrPhotoDisplayer

class FlickrPhotoDisplayerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testFlickrModelReloadMethod() {

        class MockSession: NSURLSession {
            var completionHandler: ((NSData!, NSURLResponse!, NSError!) -> Void)?

            static var mockResponse: (data: NSData?, urlResponse: NSURLResponse?, error: NSError?) = (data: nil, urlResponse: nil, error: nil)

            override class func sharedSession() -> NSURLSession {
                return MockSession()
            }

            override func dataTaskWithRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask {
                self.completionHandler = completionHandler
                return MockTask(response: MockSession.mockResponse, completionHandler: completionHandler)
            }

            class MockTask: NSURLSessionDataTask {
                typealias Response = (data: NSData?, urlResponse: NSURLResponse?, error: NSError?)
                var mockResponse: Response
                let completionHandler: ((NSData!, NSURLResponse!, NSError!) -> Void)?

                init(response: Response, completionHandler: ((NSData!, NSURLResponse!, NSError!) -> Void)?) {
                    self.mockResponse = response
                    self.completionHandler = completionHandler
                }
                override func resume() {
                    completionHandler!(mockResponse.data, mockResponse.urlResponse, mockResponse.error)
                }
            }
        }

        class Flickr: FlickrModel {
            override init() {
            }
        }

        let responseArrived = self.expectationWithDescription("response of async request has arrived")
        let model = Flickr()
        var photographers = [Photographer]()

        let jsonData = try! NSJSONSerialization.dataWithJSONObject(["photos": ""], options: .PrettyPrinted)

        let urlResponse = NSHTTPURLResponse(URL: NSURL(string: "https://snaptee.co/")!, statusCode: 200, HTTPVersion: nil, headerFields: nil)

        MockSession.mockResponse = (jsonData, urlResponse: urlResponse, error: nil)
        model.session = MockSession()
        model.reload { (p) -> Void in
            photographers = p
            responseArrived.fulfill()
        }
        self.waitForExpectationsWithTimeout(30.0) { (error) -> Void in
            XCTAssertEqual(photographers.count, 0)
        }
    }

    func testFlickrModelFetchMethodWithOHHTTPStubs() {
        let model = FlickrModel()
        var photographers = [Photographer]()
        let responseArrived = self.expectationWithDescription("response of async request has arrived")

        let s = NSBundle.mainBundle().pathForResource("photos", ofType: "json")
        stub(isHost("api.flickr.com")) { _ in
            let stubData = NSData(contentsOfFile: s!)
            return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
        }

        model.fetch { (p) -> Void in
            photographers = p
            responseArrived.fulfill()
        }

        self.waitForExpectationsWithTimeout(30.0) { (error) -> Void in
            XCTAssertEqual(photographers.count, 4)
        }
    }

    func testFlickrModelFetchMethodErrorWithOHHTTPStubs() {
        let model = FlickrModel()
        var photographers = [Photographer]()
        let responseArrived = self.expectationWithDescription("response of async request has arrived")

        let s = NSBundle.mainBundle().pathForResource("photos", ofType: "json")
        stub(isHost("api.flickr.com")) { _ in
            let stubData = NSData(contentsOfFile: s!)
            return OHHTTPStubsResponse(data: stubData!, statusCode:404, headers:nil)
        }

        model.fetch { (p) -> Void in
            photographers = p
            responseArrived.fulfill()
        }

        self.waitForExpectationsWithTimeout(30.0) { (error) -> Void in
            XCTAssertEqual(photographers.count, 4)
        }
    }

    func testFlickrModelFetchMethodEmptyJSONWithOHHTTPStubs() {
        let model = FlickrModel()
        var photographers = [Photographer]()
        let responseArrived = self.expectationWithDescription("response of async request has arrived")

        stub(isHost("api.flickr.com")) { _ in
            let stubData = "".dataUsingEncoding(NSUTF8StringEncoding)
            return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
        }

        model.fetch { (p) -> Void in
            photographers = p
            responseArrived.fulfill()
        }

        self.waitForExpectationsWithTimeout(30.0) { (error) -> Void in
            XCTAssertEqual(photographers.count, 0)
        }
    }

//    func testDownNetworkConnect() {
//        let notConnectedError = NSError(domain:NSURLErrorDomain, code:Int(CFNetworkErrors.CFURLErrorNotConnectedToInternet.rawValue), userInfo:nil)
//        return OHHTTPStubsResponse(error:notConnectedError)
//    }

}