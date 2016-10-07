import Foundation

class SessionDataTask: URLSessionDataTask {

    // MARK: - Properties

    weak var session: Session!
    let request: URLRequest
    let completion: ((Data?, Foundation.URLResponse?, NSError?) -> Void)?


    // MARK: - Initializers

    init(session: Session, request: URLRequest, completion: ((Data?, Foundation.URLResponse?, NSError?) -> Void)? = nil) {
        self.session = session
        self.request = request
        self.completion = completion
    }


    // MARK: - NSURLSessionDataTask
    
    override func cancel() {
        // Don't do anything
    }

    override func resume() {
        let cassette = session.cassette

        // Find interaction
        if let interaction = cassette?.interactionForRequest(request) {
            // Forward completion
            completion?(interaction.responseData, interaction.response, nil)
            return
        }

		if cassette != nil {
			fatalError("[DVR] Invalid request. The request was not found in the cassette.")
		}

        // Cassette is missing. Record.
		if session.recordingEnabled == false {
			fatalError("[DVR] Recording is disabled.")
		}

        // Create directory
        let outputDirectory = (session.outputDirectory as NSString).expandingTildeInPath
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: outputDirectory) {
            try! fileManager.createDirectory(atPath: outputDirectory, withIntermediateDirectories: true, attributes: nil)
        }

        print("[DVR] Recording '\(session.cassetteName)'")

        let task = session.backingSession.dataTask(with: request, completionHandler: { data, response, error in
            
            //Ensure we have a response
            guard let response = response else {
                fatalError("[DVR] Failed to persist cassette, because the task returned a nil response.")
            }
            
            // Create cassette
            let interaction = Interaction(request: self.request, response: response, responseData: data)
            let cassette = Cassette(name: self.session.cassetteName, interactions: [interaction])

            // Persist
            do {
                let outputPath = ((outputDirectory as NSString).appendingPathComponent(self.session.cassetteName) as NSString).appendingPathExtension("json")!
                let data = try JSONSerialization.data(withJSONObject: cassette.dictionary, options: [.prettyPrinted])
                if (try? data.write(to: URL(fileURLWithPath: outputPath), options: [.atomic])) != nil {
                    fatalError("[DVR] Persisted cassette at \(outputPath). Please add this file to your test target")
                }
            } catch {
                // Do nothing
            }

			fatalError("[DVR] Failed to persist cassette.")
        }) 
        task.resume()
    }
}
