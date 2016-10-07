import Foundation

extension HTTPURLResponse {
    convenience init?(dictionary: [String: Any]) {
        let maybeUrlString = dictionary["url"] as? String
        let urlString = maybeUrlString ?? "/"
        let url = URL(string: urlString)!
        let headers = dictionary["headers"] as? [String: String]
        let status: Int = dictionary["status"] as? Int ?? 0
        self.init(url: url, statusCode: status, httpVersion: nil, headerFields: headers)
    }
}
