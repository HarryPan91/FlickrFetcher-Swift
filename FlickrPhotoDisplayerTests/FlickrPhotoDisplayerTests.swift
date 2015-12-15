//
//  FlickrPhotoDisplayerTests.swift
//  FlickrPhotoDisplayerTests
//
//  Created by Harry on 2/12/2015.
//  Copyright © 2015 Snaptee. All rights reserved.
//

import XCTest
@testable import FlickrPhotoDisplayer

class FlickrPhotoDisplayerTests: XCTestCase {

    var model = Flickr()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFlickrModelFetchMethod() {

        let jsonData = try! NSJSONSerialization.dataWithJSONObject(["photos": ""], options: .PrettyPrinted)

        let urlResponse = NSHTTPURLResponse(URL: NSURL(string: "https://snaptee.co/")!, statusCode: 200, HTTPVersion: nil, headerFields: nil)

        MockSession.mockResponse = (jsonData, urlResponse: urlResponse, error: nil)
        model.mySession = MockSession.self
        model.fetch()
        XCTAssertNotNil(model.photographers)

    }

}

class Flickr: FlickrModel {
    override init() {
    }
}


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