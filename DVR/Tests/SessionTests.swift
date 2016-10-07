import XCTest
@testable import DVR

class SessionTests: XCTestCase {
    let session = Session(cassetteName: "example")
    let request = URLRequest(url: URL(string: "http://example.com")!)

    func testInit() {
        XCTAssertEqual("example", session.cassetteName)
    }

    func testDataTask() {
        let request = URLRequest(url: URL(string: "http://example.com")!)
        XCTAssert(session.dataTask(with: request) is SessionDataTask)
        XCTAssert(session.dataTask(with: request, completionHandler: { _, _, _ in return })  is SessionDataTask)
    }

    func testPlayback() {
        session.recordingEnabled = false
        let expectation = self.expectation(description: "Network")

        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            XCTAssertEqual("hello", String(data: data!, encoding: String.Encoding.utf8))

			let HTTPResponse = response as! HTTPURLResponse
			XCTAssertEqual(200, HTTPResponse.statusCode)

            expectation.fulfill()
        }) 
        task.resume()
        waitForExpectations(timeout: 1, handler: nil)
    }
}
