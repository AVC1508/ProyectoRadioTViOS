import SwiftUI

struct TVListView: View {

    @State private var viewModel = TVViewModel()

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
                        ProgressView("Cargando canales...")
                            .tint(.cyan)
                            .foregroundStyle(.white)

                    } else if !viewModel.errorMessage.isEmpty {
                        VStack(spacing: 15) {
                            Image(systemName: "tv.slash")
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
                                    await viewModel.loadChannels()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()

                    } else {
                        List(viewModel.channels) { channel in
                            NavigationLink {
                                VideoPlayerView(channel: channel)
                            } label: {
                                HStack(spacing: 15) {
                                    Image(systemName: "tv")
                                        .font(.system(size: 25))
                                        .foregroundStyle(.cyan)

                                    Text(channel.name)
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                }
                                .padding(.vertical, 8)
                            }
                            .listRowBackground(Color.white.opacity(0.08))
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Canales de televisión")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .task {
                if viewModel.channels.isEmpty &&
                    viewModel.errorMessage.isEmpty {
                    await viewModel.loadChannels()
                }
            }
        }
    }
}

#Preview {
    TVListView()
}
