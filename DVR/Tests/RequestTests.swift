//
//  ResponseTests.swift
//  DVR
//
//  Created by Honza Dvorsky on 28/06/2015.
//  Copyright © 2015 Venmo. All rights reserved.
//

import XCTest
@testable
import DVR

//extension HTTPURLResponse {
//    
//    convenience init?(contentType: String) {
//        let dict: [String: Any] = ["Content-Type" : contentType]
//        self.init(dictionary: dict)
//    }
//}


extension URLRequest {
    
    init?(contentType: String, data: Data) {
        let headersDict: [String: String] = ["Content-Type": contentType]
        let dict: [String: Any] = ["headers": headersDict, "body": data]
        self.init(dictionary: dict)
    }
}

class RequestTests: XCTestCase {

    func testDataSerialization_JSON() {
        
        let object: NSDictionary = [
            "testing": "rules"
        ]
        let data = try! JSONSerialization.data(withJSONObject: object, options: [])
        guard let request = URLRequest(contentType: "application/json", data: data) else { XCTFail(); return }
        let interaction = Interaction(request: request, response: HTTPURLResponse(), responseData: nil)
        
        let dictionary = interaction.dictionary["request"] as! NSDictionary
        XCTAssertNotNil(dictionary["body"])
        XCTAssertNotNil(dictionary["body_format"])
        XCTAssertEqual(dictionary["body"] as! NSDictionary, object)
        XCTAssertEqual(dictionary["body_format"] as! String, SerializationFormat.JSON.rawValue)
    }
    
    func testDataSerialization_PlainText() {
        
        let object: String = "testing_rules"
        let data = object.data(using: String.Encoding.utf8)!
        
        guard let request = URLRequest(contentType: "text/plain", data: data) else { XCTFail(); return }
        let interaction = Interaction(request: request, response: HTTPURLResponse(), responseData: nil)
        
        let dictionary = interaction.dictionary["request"] as! NSDictionary
        XCTAssertNotNil(dictionary["body"])
        XCTAssertNotNil(dictionary["body_format"])
        XCTAssertEqual(dictionary["body"] as! String, object)
        XCTAssertEqual(dictionary["body_format"] as! String, SerializationFormat.PlainText.rawValue)
    }
    
    func testDataSerialization_Base64() {
        
        let object: String = "testing_rules"
        let data = object.data(using: String.Encoding.utf8)!
        let base64String = data.base64EncodedString(options: [])
        
        
        guard let request = URLRequest(contentType: "application/octet-stream", data: data) else { XCTFail(); return }
        let interaction = Interaction(request: request, response: HTTPURLResponse(), responseData: nil)
        
        let dictionary = interaction.dictionary["request"] as! NSDictionary
        XCTAssertNotNil(dictionary["body"])
        XCTAssertNotNil(dictionary["body_format"])
        XCTAssertEqual(dictionary["body"] as! String, base64String)
        XCTAssertEqual(dictionary["body_format"] as! String, SerializationFormat.Base64String.rawValue)
    }
    
    func testDataDeserialization_JSON() {
        
        let json: NSDictionary = [
            "testing": "rules?"
        ]
        let request: [String: AnyObject] = [
            "body": json,
            "body_format": SerializationFormat.JSON.rawValue as AnyObject
        ]
        
        let dictionary: [String: AnyObject] = [
            "request": request as AnyObject,
            "recorded_at": 12345 as AnyObject,
            "response": [String: AnyObject]() as AnyObject
        ]
        
        let interaction = Interaction(dictionary: dictionary)!
        let data = interaction.request.httpBody!
        let parsed = try! JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as! NSDictionary
        XCTAssertEqual(json, parsed)
    }
    
    func testDataDeserialization_PlainText() {
        
        let string = "testing_rules?"
        let request: [String: AnyObject] = [
            "body": string as AnyObject,
            "body_format": SerializationFormat.PlainText.rawValue as AnyObject
        ]
        
        let dictionary: [String: AnyObject] = [
            "request": request as AnyObject,
            "recorded_at": 12345 as AnyObject,
            "response": [String: AnyObject]() as AnyObject
        ]
        
        let interaction = Interaction(dictionary: dictionary)!
        let requestData = interaction.request.httpBody!

        let parsed = String(data: requestData, encoding: String.Encoding.utf8)
        XCTAssertEqual(string, parsed)
    }
    
    func testDataDeserialization_Base64() {
        
        let string = "testing_rules?"
        let data = string.data(using: String.Encoding.utf8)!
        let base64String = data.base64EncodedString()
        let request: [String: AnyObject] = [
            "body": base64String as AnyObject,
            "body_format": SerializationFormat.Base64String.rawValue as AnyObject
        ]
        
        let dictionary: [String: AnyObject] = [
            "request": request as AnyObject,
            "recorded_at": 12345 as AnyObject,
            "response": [String: AnyObject]() as AnyObject
        ]
        
        let interaction = Interaction(dictionary: dictionary)!
        let requestData = interaction.request.httpBody!
        
        let parsed = String(data: requestData, encoding: String.Encoding.utf8)
        XCTAssertEqual(string, parsed)
    }
    
    func testDataDeserialization_defaultsToBase64() {
        
        let string = "no_format_specified, so base64 is assumed!"
        let data = string.data(using: String.Encoding.utf8)
        let base64String = data?.base64EncodedData()
        let request: [String: AnyObject] = [
            "body": base64String as AnyObject
        ]
        
        let dictionary: [String: AnyObject] = [
            "request": request as AnyObject,
            "recorded_at": 12345 as AnyObject,
            "response": [String: AnyObject]() as AnyObject
        ]
        
        let interaction = Interaction(dictionary: dictionary)!
        let requestData = interaction.request.httpBody!
        
        let parsed = String(data: requestData, encoding: String.Encoding.utf8)
        XCTAssertEqual(string, parsed)
    }
    
}
