import Foundation

struct Interaction {
    let request: URLRequest
    let response: Foundation.URLResponse
    let responseData: Data?
    let recordedAt: Date

    init(request: URLRequest, response: Foundation.URLResponse, responseData: Data? = nil, recordedAt: Date = Date()) {
        self.request = request
        self.response = response
        self.responseData = responseData
        self.recordedAt = recordedAt
    }
    
    init(response: Foundation.URLResponse, responseData: Data? = nil, recordedAt: Date = Date()) {
        guard let url = URL(string: "/") else { fatalError("no url") }
        let urlRequest = URLRequest(url: url)
        self.init(request: urlRequest, response: response, responseData: responseData, recordedAt: recordedAt)
    }
    
}

extension Interaction {
    
    var dictionary: [String: Any] {
        var dictionary: [String: Any] = [
            "request": request.dictionary,
            "recorded_at": recordedAt.timeIntervalSince1970
        ]
        
        var contentType: String?
        if let httpResponse = self.response as? HTTPURLResponse {
            contentType = httpResponse.allHeaderFields["Content-Type"] as? String
        }
        
        var response = self.response.dictionary
        if let data = responseData {
            let (format, body) = DataSerialization.serializeBodyData(data, contentType: contentType)
            response["body"] = body
            response["body_format"] = format.rawValue
        }
        dictionary["response"] = response
        
        return dictionary
    }

    init?(dictionary: [String: Any]) {
        guard let requestDictionary = dictionary["request"] as? [String: Any],
            let responseDictionary = dictionary["response"] as? [String: Any],
            let recordedAt = dictionary["recorded_at"] as? Int,
            let request = URLRequest(dictionary: requestDictionary),
            let response = HTTPURLResponse(dictionary: responseDictionary)
            else { return nil }

        self.request = request
        self.response = response
        self.recordedAt = Date(timeIntervalSince1970: TimeInterval(recordedAt))

        if let body = responseDictionary["body"] {
            let formatString = responseDictionary["body_format"] as? String ?? ""
            let format = SerializationFormat(rawValue: formatString) ?? .base64String
            self.responseData = DataSerialization.deserializeBodyData(format, object: body)
        } else {
            self.responseData = nil
        }
    }
}

