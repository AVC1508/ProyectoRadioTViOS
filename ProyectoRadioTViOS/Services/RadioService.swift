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

private struct RadioAPIResponse: Decodable {
    let data: [RadioStation]
}

@MainActor
class RadioService {

    func fetchStations() async throws -> [RadioStation] {

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

        guard !result.data.isEmpty else {
            throw RadioServiceError.noStations
        }

        return result.data
    }
}
