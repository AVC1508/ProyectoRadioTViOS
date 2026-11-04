import Foundation

enum TVServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case noChannels

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "La dirección de la lista de televisión no es válida."
        case .invalidResponse:
            return "No se pudo descargar la lista de canales."
        case .noChannels:
            return "No hay canales disponibles."
        }
    }
}

@MainActor
class TVService {

    func fetchChannels() async throws -> [TVChannel] {

        let urlString = "https://iptv-org.github.io/iptv/countries/mx.m3u"

        guard let url = URL(string: urlString) else {
            throw TVServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 20

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200,
              let content = String(data: data, encoding: .utf8) else {
            throw TVServiceError.invalidResponse
        }

        let lines = content.components(separatedBy: .newlines)

        var channels: [TVChannel] = []
        var currentName: String?

        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)

            if trimmedLine.hasPrefix("#EXTINF:") {
                if let commaIndex = trimmedLine.lastIndex(of: ",") {
                    currentName = String(
                        trimmedLine[trimmedLine.index(after: commaIndex)...]
                    ).trimmingCharacters(in: .whitespaces)
                }

            } else if !trimmedLine.isEmpty,
                      !trimmedLine.hasPrefix("#"),
                      let name = currentName {

                channels.append(
                    TVChannel(
                        name: name,
                        streamURL: trimmedLine
                    )
                )

                currentName = nil
            }
        }

        guard !channels.isEmpty else {
            throw TVServiceError.noChannels
        }

        return channels
    }
}
