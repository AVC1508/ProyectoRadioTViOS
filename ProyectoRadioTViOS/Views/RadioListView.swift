import SwiftUI

struct RadioListView: View {

    @State private var viewModel = RadioViewModel()
    @State private var searchText = ""

    // Filtrar estaciones por nombre, género o país
    private var filteredStations: [RadioStation] {
        guard !searchText.isEmpty else {
            return viewModel.stations
        }

        return viewModel.stations.filter { station in
            station.name.localizedCaseInsensitiveContains(searchText) ||
            station.displayGenre.localizedCaseInsensitiveContains(searchText) ||
            station.displayCountry.localizedCaseInsensitiveContains(searchText)
        }
    }

    // Mostrar solamente dos etiquetas del género
    private func shortGenre(_ station: RadioStation) -> String {
        let genres = station.displayGenre
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return genres.prefix(2).joined(separator: " · ")
    }

    var body: some View {
        NavigationStack {
            ZStack {

                LinearGradient(
                    colors: [
                        Color(red: 0.04, green: 0.08, blue: 0.17),
                        Color(red: 0.08, green: 0.16, blue: 0.29)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                Group {
                    if viewModel.isLoading {

                        ProgressView("Cargando estaciones...")
                            .tint(.cyan)
                            .foregroundStyle(.white)

                    } else if !viewModel.errorMessage.isEmpty {

                        VStack(spacing: 15) {
                            Image(systemName: "wifi.slash")
                                .font(.system(size: 45))
                                .foregroundStyle(.cyan)

                            Text("Contenido no disponible")
                                .font(.title2.bold())
                                .foregroundStyle(.white)

                            Text(viewModel.errorMessage)
                                .foregroundStyle(.white.opacity(0.7))
                                .multilineTextAlignment(.center)

                            Button("Intentar nuevamente") {
                                Task {
                                    await viewModel.loadStations()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()

                    } else {

                        List {
                            if filteredStations.isEmpty {

                                Text("No se encontraron estaciones.")
                                    .foregroundStyle(.white.opacity(0.7))
                                    .listRowBackground(Color.clear)

                            } else {

                                ForEach(filteredStations) { station in

                                    NavigationLink {
                                        AudioPlayerView(station: station)
                                    } label: {

                                        VStack(alignment: .leading, spacing: 10) {

                                            Text(station.name)
                                                .font(.headline)
                                                .foregroundStyle(.white)
                                                .lineLimit(2)

                                            HStack(spacing: 12) {

                                                Label(
                                                    shortGenre(station),
                                                    systemImage: "music.note"
                                                )
                                                .lineLimit(1)
                                                .truncationMode(.tail)

                                                Spacer(minLength: 4)

                                                Label(
                                                    station.displayCountry,
                                                    systemImage: "globe"
                                                )
                                                .lineLimit(1)
                                            }
                                            .font(.caption)
                                            .foregroundStyle(.white.opacity(0.7))
                                        }
                                        .padding(.vertical, 8)
                                    }
                                    .listRowBackground(Color.white.opacity(0.08))
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .searchable(
                            text: $searchText,
                            prompt: "Buscar radio, género o país"
                        )
                    }
                }
            }
            .navigationTitle("Estaciones de radio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .task {
                if viewModel.stations.isEmpty &&
                    viewModel.errorMessage.isEmpty {
                    await viewModel.loadStations()
                }
            }
        }
    }
}

#Preview {
    RadioListView()
}
