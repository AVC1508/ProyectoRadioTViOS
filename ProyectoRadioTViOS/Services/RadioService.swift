import Foundation

enum RadioServiceError: LocalizedError {

    case invalidURL
    case invalidResponse
    case apiError
    case noStations

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "La dirección de la API no es válida."
        case .invalidResponse:
            return "No se recibió una respuesta válida."
        case .apiError:
            return "No se pudieron descargar las estaciones."
        case .noStations:
            return "No hay estaciones disponibles."
        }
    }
}

// Respuesta de RapidAPI
private struct RadioAPIResponse: Decodable {
    let data: [RadioStation]
}

// Respuesta de Radio Browser
private struct RadioBrowserStation: Decodable {
    let stationuuid: String
    let name: String
    let country: String
    let tags: String
    let url_resolved: String
    let codec: String
    let bitrate: Int
    let lastcheckok: Int
}

@MainActor
class RadioService {

    func fetchStations() async throws -> [RadioStation] {

        // Primero intentamos descargar estaciones de México
        let mexicanStations = (try? await fetchMexicanStations()) ?? []

        // Después descargamos estaciones internacionales
        let internationalStations = (try? await fetchInternationalStations()) ?? []

        let allStations = mexicanStations + internationalStations

        guard !allStations.isEmpty else {
            throw RadioServiceError.noStations
        }

        return allStations
    }

    // Descargar estaciones mexicanas desde Radio Browser
    private func fetchMexicanStations() async throws -> [RadioStation] {

        let urlString = "https://de1.api.radio-browser.info/json/stations/bycountrycodeexact/MX?limit=20&hidebroken=true&order=votes&reverse=true"

        guard let url = URL(string: urlString) else {
            throw RadioServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 20

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw RadioServiceError.apiError
        }

        let result = try JSONDecoder().decode(
            [RadioBrowserStation].self,
            from: data
        )

        return result.map { station in

            let genre = RadioGenre(
                text: station.tags.isEmpty ? nil : station.tags
            )

            let location = RadioLocation(
                countryName: station.country
            )

            let stream = RadioStream(
                url: station.url_resolved,
                isHttps: station.url_resolved.lowercased().hasPrefix("https"),
                codec: station.codec,
                bitrate: station.bitrate,
                works: station.lastcheckok == 1
            )

            return RadioStation(
                id: station.stationuuid,
                name: station.name,
                genre: genre,
                location: location,
                streams: [stream]
            )
        }
    }

    // Descargar estaciones internacionales desde RapidAPI
    private func fetchInternationalStations() async throws -> [RadioStation] {

        let urlString = "https://50k-radio-stations.p.rapidapi.com/radios/random?limit=20"

        guard let url = URL(string: urlString) else {
            throw RadioServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        request.setValue(
            "50k-radio-stations.p.rapidapi.com",
            forHTTPHeaderField: "x-rapidapi-host"
        )

        request.setValue(
            Secrets.rapidAPIKey,
            forHTTPHeaderField: "x-rapidapi-key"
        )

        request.timeoutInterval = 20

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw RadioServiceError.apiError
        }

        let result = try JSONDecoder().decode(
            RadioAPIResponse.self,
            from: data
        )

        return result.data
    }
}
