import SwiftUI
import AVKit

struct VideoPlayerView: View {

    let channel: TVChannel

    @State private var player: AVPlayer?
    @State private var isLoading = true
    @State private var errorMessage = ""
    @State private var statusObservation: NSKeyValueObservation?
    @State private var timeoutTask: Task<Void, Never>?

    var body: some View {

        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {

                Text(channel.name)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)

                if let player = player,
                   errorMessage.isEmpty {

                    VideoPlayer(player: player)
                        .frame(height: 260)

                } else if isLoading {

                    ProgressView("Conectando con el canal...")
                        .tint(.cyan)
                        .foregroundStyle(.white)
                        .frame(height: 260)

                } else {

                    VStack(spacing: 15) {

                        Image(systemName: "tv.slash")
                            .font(.system(size: 50))
                            .foregroundStyle(.cyan)

                        Text("Contenido no disponible")
                            .font(.headline)
                            .foregroundStyle(.white)

                        Text(errorMessage)
                            .foregroundStyle(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .frame(height: 260)
                    .padding()
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Televisión")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            startPlayback()
        }
        .onDisappear {
            stopPlayback()
        }
    }

    private func startPlayback() {

        guard let url = URL(string: channel.streamURL),
              let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https" else {

            errorMessage = "La dirección del canal no es válida."
            isLoading = false
            return
        }

        let item = AVPlayerItem(url: url)
        let newPlayer = AVPlayer(playerItem: item)

        player = newPlayer
        isLoading = true
        errorMessage = ""

        statusObservation = item.observe(
            \.status,
            options: [.initial, .new]
        ) { item, _ in

            Task { @MainActor in

                switch item.status {

                case .readyToPlay:

                    isLoading = false
                    timeoutTask?.cancel()
                    timeoutTask = nil
                    newPlayer.play()

                case .failed:

                    isLoading = false
                    errorMessage = "No se pudo reproducir este canal."
                    timeoutTask?.cancel()
                    timeoutTask = nil
                    newPlayer.pause()

                default:
                    break
                }
            }
        }

        timeoutTask?.cancel()

        timeoutTask = Task { @MainActor in

            try? await Task.sleep(for: .seconds(20))

            guard !Task.isCancelled,
                  player === newPlayer,
                  isLoading else {
                return
            }

            isLoading = false
            errorMessage = "El canal tardó demasiado en responder o no está disponible."

            newPlayer.pause()
        }
    }

    private func stopPlayback() {

        timeoutTask?.cancel()
        timeoutTask = nil

        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil

        statusObservation?.invalidate()
        statusObservation = nil

        isLoading = false
    }
}

#Preview {
    NavigationStack {
        VideoPlayerView(
            channel: TVChannel(
                name: "Canal de prueba",
                streamURL: "https://example.com/video.m3u8"
            )
        )
    }
}
