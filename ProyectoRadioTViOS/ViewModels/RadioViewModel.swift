import Foundation
import Observation

@MainActor
@Observable
class RadioViewModel {

    var stations: [RadioStation] = []
    var isLoading = false
    var errorMessage = ""

    private let radioService = RadioService()

    func loadStations() async {

        guard !isLoading else { return }

        isLoading = true
        errorMessage = ""

        defer {
            isLoading = false
        }

        do {
            stations = try await radioService.fetchStations()

            if stations.isEmpty {
                errorMessage = "No hay estaciones disponibles."
            }

        } catch {
            stations = []
            errorMessage = error.localizedDescription
        }
    }
}
