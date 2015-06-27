import XCTest
@testable import DVR

class SessionTests: XCTestCase {
    let session = Session(cassetteName: "example")
    let request = NSURLRequest(URL: NSURL(string: "http://example.com")!)

    func testInit() {
        XCTAssertEqual("example", session.cassetteName)
    }

    func testDataTask() {
        let request = NSURLRequest(URL: NSURL(string: "http://example.com")!)
        XCTAssert(session.dataTaskWithRequest(request) is SessionDataTask)
        XCTAssert(session.dataTaskWithRequest(request) { _, _, _ in return } is SessionDataTask)
    }

    func testPlayback() {
        session.recordingEnabled = false
        let expectation = expectationWithDescription("Network")

        let task = session.dataTaskWithRequest(request) { data, response, error in
            XCTAssertEqual("hello", String(NSString(data: data!, encoding: NSUTF8StringEncoding)!))

			let HTTPResponse = response as! NSHTTPURLResponse
			XCTAssertEqual(200, HTTPResponse.statusCode)

            expectation.fulfill()
        }
        task?.resume()
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testSessionReturnsNilResponse() {
        session.recordingEnabled = false
        let expectation = expectationWithDescription("Network")
        
        let backingSession = SessionReturningNilResponse()
        let testSession = Session(cassetteName: "nilly", backingSession: backingSession)
        let testRequest = NSURLRequest(URL: NSURL(string: "https://nil.ly")!)

        let task = testSession.dataTaskWithRequest(testRequest) { data, response, error in
            
            //something like 
//            XCTAssertThrowsFatalError() - ensure that fatal error was called.
            expectation.fulfill()
        }
        task?.resume()
        waitForExpectationsWithTimeout(1, handler: nil)
    }
}

class SessionNoopTask: NSURLSessionDataTask {
    
    let completion: () -> ()
    
    init(completion: () -> ()) {
        self.completion = completion
    }
    
    override func resume() {
        //nada, just complete
        self.completion()
    }
}

class SessionReturningNilResponse: NSURLSession {
    override func dataTaskWithRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask? {
        
        return SessionNoopTask(completion: { () -> () in
            completionHandler(NSData(), nil, nil)
        })
    }
}
