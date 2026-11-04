import Foundation

struct RadioStation: Identifiable, Decodable {
    let id: Int
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
