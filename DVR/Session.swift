import Foundation

open class Session: URLSession {

    // MARK: - Properties

    open var outputDirectory: String
    open let cassetteName: String
    open let backingSession: URLSession
    open var recordingEnabled = true
    fileprivate let testBundle: Bundle


    // MARK: - Initializers

    public init(outputDirectory: String = "~/Desktop/DVR/", cassetteName: String, testBundle: Bundle = Bundle.allBundles.filter() { $0.bundlePath.hasSuffix(".xctest") }.first!, backingSession: URLSession = URLSession.shared) {
        self.outputDirectory = outputDirectory
        self.cassetteName = cassetteName
        self.testBundle = testBundle
        self.backingSession = backingSession
        super.init()
    }


    // MARK: - NSURLSession

    open override func dataTask(with request: URLRequest) -> URLSessionDataTask {
        return SessionDataTask(session: self, request: request)
    }

    open override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, Foundation.URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return SessionDataTask(session: self, request: request, completion: completionHandler)
    }
    
    open override func invalidateAndCancel() {
        // Don't do anything
    }

    // MARK: - Internal

    var cassette: Cassette? {
        guard let path = testBundle.path(forResource: cassetteName, ofType: "json"), let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return nil }
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                return Cassette(dictionary: json)
            }
        } catch {}
        return nil
    }
}
