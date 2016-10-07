//
//  DataSerialization.swift
//  DVR
//
//  Created by Honza Dvorsky on 04/07/2015.
//  Copyright © 2015 Venmo. All rights reserved.
//

import Foundation

// Identifies the way data was persisted on disk
enum SerializationFormat: String {
    case JSON = "json"
    case PlainText = "plain_text"
    case Base64String = "base64_string" //legacy default
}

// Body data serialization
class DataSerialization {
    
    static func serializeBodyData(_ data: Data, contentType: String?) -> (format: SerializationFormat, object: Any) {
        
        //JSON
        if let contentType = contentType , contentType.hasPrefix("application/json") {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                return (format: .JSON, json)
            } catch { /* nope, not a valid json. nevermind. */ }
        }
        
        //Plain Text
        if let contentType = contentType , contentType.hasPrefix("text") {
            if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                return (format: .PlainText, object: string)
            }
        }
        
        //nope, might be image data or something else
        //no prettier representation, fall back to base64 string
        let string = data.base64EncodedString(options: [])
        return (format: .Base64String, object: string)
    }
    
    static func deserializeBodyData(_ format: SerializationFormat, object: Any) -> Data {
        
        switch format {
        case .JSON:
            do {
                return try JSONSerialization.data(withJSONObject: object, options: [])
            } catch { fatalError("Failed to convert JSON object \(object) into data") }
        case .PlainText:
            return (object as! String).data(using: String.Encoding.utf8)!
        case .Base64String:
            if let base64String = object as? String {
                return Data(base64Encoded: base64String, options: .ignoreUnknownCharacters)!
            } else if let base64Data = object as? Data {
                return Data(base64Encoded: base64Data, options: .ignoreUnknownCharacters)!
            } else {
                fatalError("fail")
            }
        }
    }
    
}
