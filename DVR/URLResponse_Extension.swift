import Foundation

extension URLResponse {
    
    convenience init?(dictionary: [String: Any]) {
        guard
            let urlString = dictionary["url"] as? String,
            let url = URL(string: urlString)
            else { return nil }
//        let urlString: String = dictionary["url"] as? String ?? "/"
//        let url = URL(string: urlString)!
        self.init(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    var dictionary: [String: Any] {
        if let url = url?.absoluteString {
            return ["url": url]
        }

        return [:]
    }
}
