import Foundation

extension URLRequest {
    var dictionary: [String: Any] {
        var dictionary = [String: Any]()

        if let method = httpMethod {
            dictionary["method"] = method
        }

        if let url = url?.absoluteString {
            dictionary["url"] = url
        }

        var contentType: String?
        if let headers = allHTTPHeaderFields {
            dictionary["headers"] = headers
            contentType = headers["Content-Type"]
        }

        if let body = httpBody {
            let (format, bodyObject) = DataSerialization.serializeBodyData(body, contentType: contentType)
            dictionary["body"] = bodyObject
            dictionary["body_format"] = format.rawValue
        }

        return dictionary
    }
}


extension URLRequest {
    init?(dictionary: [String: Any]) {
   
        let maybeUrlString = dictionary["url"] as? String
        let urlString = maybeUrlString ?? "/"
        let url = URL(string: urlString)!
        
        self.init(url: url)

        if let method = dictionary["method"] as? String {
            httpMethod = method
        }

        if let headers = dictionary["headers"] as? [String: String] {
            allHTTPHeaderFields = headers
        }

        if let body = dictionary["body"] {
            let formatString = dictionary["body_format"] as? String ?? ""
            let format = SerializationFormat(rawValue: formatString) ?? .base64String
            httpBody = DataSerialization.deserializeBodyData(format, object: body)
        }
    }
}
