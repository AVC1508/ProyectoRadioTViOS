import SwiftUI

struct RadioListView: View {

    @State private var viewModel = RadioViewModel()

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
                        List(viewModel.stations) { station in

                            NavigationLink {
                                AudioPlayerView(station: station)

                            } label: {

                                VStack(alignment: .leading, spacing: 6) {

                                    Text(station.name)
                                        .font(.headline)
                                        .foregroundStyle(.white)

                                    HStack {

                                        Label(
                                            station.displayGenre,
                                            systemImage: "music.note"
                                        )

                                        Spacer()

                                        Label(
                                            station.displayCountry,
                                            systemImage: "globe"
                                        )
                                    }
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.7))
                                }
                                .padding(.vertical, 6)
                            }
                            .listRowBackground(Color.white.opacity(0.08))
                        }
                        .scrollContentBackground(.hidden)
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
