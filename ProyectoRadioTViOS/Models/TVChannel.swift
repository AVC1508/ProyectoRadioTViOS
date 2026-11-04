import Foundation

struct TVChannel: Identifiable {
    let id: UUID
    let name: String
    let streamURL: String

    init(
        id: UUID = UUID(),
        name: String,
        streamURL: String
    ) {
        self.id = id
        self.name = name
        self.streamURL = streamURL
    }
}
