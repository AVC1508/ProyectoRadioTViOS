import Foundation
import Observation

@MainActor
@Observable
class TVViewModel {

    var channels: [TVChannel] = []
    var isLoading = false
    var errorMessage = ""

    private let tvService = TVService()

    func loadChannels() async {

        guard !isLoading else { return }

        isLoading = true
        errorMessage = ""

        defer {
            isLoading = false
        }

        do {
            channels = try await tvService.fetchChannels()

            if channels.isEmpty {
                errorMessage = "No hay canales disponibles."
            }

        } catch {
            channels = []
            errorMessage = error.localizedDescription
        }
    }
}
