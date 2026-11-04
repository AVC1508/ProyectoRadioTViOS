import Foundation

struct RadioStation: Identifiable, Decodable {

    let id: String
    let name: String
    let genre: RadioGenre?
    let location: RadioLocation?
    let streams: [RadioStream]?

    var displayGenre: String {
        genre?.text ?? "Género desconocido"
    }

    var displayCountry: String {
        location?.countryName ?? "País desconocido"
    }

    init(
        id: String,
        name: String,
        genre: RadioGenre?,
        location: RadioLocation?,
        streams: [RadioStream]?
    ) {
        self.id = id
        self.name = name
        self.genre = genre
        self.location = location
        self.streams = streams
    }

    // Aceptar identificadores numéricos o de texto
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let numericID = try? container.decode(Int.self, forKey: .id) {
            id = String(numericID)
        } else {
            id = try container.decode(String.self, forKey: .id)
        }

        name = try container.decode(String.self, forKey: .name)
        genre = try container.decodeIfPresent(RadioGenre.self, forKey: .genre)
        location = try container.decodeIfPresent(RadioLocation.self, forKey: .location)
        streams = try container.decodeIfPresent([RadioStream].self, forKey: .streams)
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, genre, location, streams
    }
}

struct RadioGenre: Decodable {
    let text: String?
}

struct RadioLocation: Decodable {
    let countryName: String?
}

struct RadioStream: Decodable {
    let url: String
    let isHttps: Bool?
    let codec: String?
    let bitrate: Int?
    let works: Bool?
}
