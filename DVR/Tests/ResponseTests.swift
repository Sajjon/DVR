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

extension HTTPURLResponse {
    
    convenience init?(contentType: String) {
        let headers: [String: String] = ["Content-Type" : contentType]
        let dict: [String: Any] = ["headers" : headers]
        self.init(dictionary: dict)
    }
}

class ResponseTests: XCTestCase {

    func testDataSerialization_JSON() {
        
        let object: NSDictionary = [
            "testing": "rules"
        ]
        let data = try! JSONSerialization.data(withJSONObject: object, options: [])
        guard let response = HTTPURLResponse(contentType: "application/json") else { XCTFail(); return }
        let interaction = Interaction(response: response, responseData: data)
        
        let dictionary = interaction.dictionary["response"] as! NSDictionary
        XCTAssertNotNil(dictionary["body"])
        XCTAssertNotNil(dictionary["body_format"])
        XCTAssertEqual(dictionary["body"] as! NSDictionary, object)
        XCTAssertEqual(dictionary["body_format"] as! String, SerializationFormat.JSON.rawValue)
    }
    
    func testDataSerialization_PlainText() {
        
        let object: String = "testing_rules"
        let data = object.data(using: String.Encoding.utf8)!
        
        guard let response = HTTPURLResponse(contentType: "text/plain") else { XCTFail(); return }
        let interaction = Interaction(response: response, responseData: data)
        
        let dictionary = interaction.dictionary["response"] as! NSDictionary
        XCTAssertNotNil(dictionary["body"])
        XCTAssertNotNil(dictionary["body_format"])
        XCTAssertEqual(dictionary["body"] as! String, object)
        XCTAssertEqual(dictionary["body_format"] as! String, SerializationFormat.PlainText.rawValue)
    }
    
    func testDataSerialization_Base64() {
        
        let object: String = "testing_rules"
        let data = object.data(using: String.Encoding.utf8)!
        let base64String = data.base64EncodedString(options: [])
        
        
        guard let response = HTTPURLResponse(contentType: "application/octet-stream") else { XCTFail(); return }
        let interaction = Interaction(response: response, responseData: data)
        
        let dictionary = interaction.dictionary["response"] as! NSDictionary
        XCTAssertNotNil(dictionary["body"])
        XCTAssertNotNil(dictionary["body_format"])
        XCTAssertEqual(dictionary["body"] as! String, base64String)
        XCTAssertEqual(dictionary["body_format"] as! String, SerializationFormat.Base64String.rawValue)
    }
    
    func testDataDeserialization_JSON() {
        
        let json: NSDictionary = [
            "testing": "rules?"
        ]
        let response: [String: AnyObject] = [
            "body": json,
            "body_format": SerializationFormat.JSON.rawValue as AnyObject
        ]
        
        let dictionary: [String: AnyObject] = [
            "request": [String: AnyObject]() as AnyObject,
            "recorded_at": 12345 as AnyObject,
            "response": response as AnyObject
        ]
        
        let interaction = Interaction(dictionary: dictionary)!
        let data = interaction.responseData!
        let parsed = try! JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as! NSDictionary
        XCTAssertEqual(json, parsed)
    }
    
    func testDataDeserialization_PlainText() {
        
        let string = "testing_rules?"
        let response: [String: AnyObject] = [
            "body": string as AnyObject,
            "body_format": SerializationFormat.PlainText.rawValue as AnyObject
        ]
        
        let dictionary: [String: AnyObject] = [
            "request": [String: AnyObject]() as AnyObject,
            "recorded_at": 12345 as AnyObject,
            "response": response as AnyObject
        ]
        
        let interaction = Interaction(dictionary: dictionary)!
        let responseData = interaction.responseData!
        
        let parsed = String(data: responseData, encoding: String.Encoding.utf8)
        XCTAssertEqual(string, parsed)
    }
    
    func testDataDeserialization_Base64() {
        
        let string = "testing_rules?"
        let data = string.data(using: String.Encoding.utf8)!
        let base64String = data.base64EncodedString()
        let response: [String: Any] = [
            "body": base64String,
            "body_format": SerializationFormat.Base64String.rawValue
        ]
        
        let dictionary: [String: AnyObject] = [
            "request": [String: AnyObject]() as AnyObject,
            "recorded_at": 12345 as AnyObject,
            "response": response as AnyObject
        ]
        
        let interaction = Interaction(dictionary: dictionary)!
        let responseData = interaction.responseData!
        
        let parsed = String(data: responseData, encoding: String.Encoding.utf8)
        XCTAssertEqual(string, parsed)
    }
    
    func testDataDeserialization_defaultsToBase64() {
        
        let string = "no_format_specified, so base64 is assumed!"
        let data = string.data(using: String.Encoding.utf8)!
        let base64String = data.base64EncodedString(options: [])
        let response: [String: Any] = [
            "body": base64String
        ]
        
        let dictionary: [String: AnyObject] = [
            "request": [String: AnyObject]() as AnyObject,
            "recorded_at": 12345 as AnyObject,
            "response": response as AnyObject
        ]
        
        let interaction = Interaction(dictionary: dictionary)!
        let responseData = interaction.responseData!
        
        let parsed = String(data: responseData, encoding: String.Encoding.utf8)
        XCTAssertEqual(string, parsed)
    }
    
}
