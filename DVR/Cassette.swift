import Foundation

struct Cassette {
    let name: String
    let interactions: [Interaction]

    init(name: String, interactions: [Interaction]) {
        self.name = name
        self.interactions = interactions
    }

    func interactionForRequest(_ request: URLRequest) -> Interaction? {
        for interaction in interactions {
            let r = interaction.request

            // Note: We don't check headers right now
            if r.httpMethod == request.httpMethod && r.url == request.url && r.httpBody == request.httpBody {
                return interaction
            }
        }
        return nil
    }
}


extension Cassette {
    var dictionary: [String: Any] {
        return [
            "name": name,
            "interactions": interactions.map { $0.dictionary }
        ]
    }

    init?(dictionary: [String: Any]) {
        guard let name = dictionary["name"] as? String else { return nil }

        self.name = name

        if let array = dictionary["interactions"] as? [[String: Any]] {
            interactions = array.flatMap { Interaction(dictionary: $0) }
        } else {
            interactions = []
        }
    }
}
