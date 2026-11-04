import Foundation
import AVFoundation
import Observation

@MainActor
@Observable
class AudioPlayerViewModel {

    var isPlaying = false
    var errorMessage = ""

    private var player: AVPlayer?
    private var statusObserver: NSKeyValueObservation?
    private var itemObserver: NSKeyValueObservation?
    private var startupTask: Task<Void, Never>?

    func play(urlString: String) {

        stop()
        errorMessage = ""

        guard let url = URL(string: urlString),
              let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https" else {

            errorMessage = "La dirección de audio no es válida."
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default
            )

            try AVAudioSession.sharedInstance().setActive(true)

        } catch {
            errorMessage = "No se pudo configurar el audio."
            return
        }

        let item = AVPlayerItem(url: url)
        let newPlayer = AVPlayer(playerItem: item)

        player = newPlayer

        // Detectar errores del elemento de audio
        itemObserver = item.observe(
            \.status,
            options: [.initial, .new]
        ) { [weak self] item, _ in

            Task { @MainActor [weak self] in
                guard let self = self else { return }

                if item.status == .failed {
                    self.showPlaybackError()
                }
            }
        }

        // Detectar cuándo comienza la reproducción
        statusObserver = newPlayer.observe(
            \.timeControlStatus,
            options: [.initial, .new]
        ) { [weak self] player, _ in

            Task { @MainActor [weak self] in
                guard let self = self else { return }

                if player.timeControlStatus == .playing {
                    self.isPlaying = true
                    self.startupTask?.cancel()
                    self.startupTask = nil

                } else {
                    self.isPlaying = false
                }
            }
        }

        newPlayer.play()
        monitorStartup(player: newPlayer)
    }

    private func monitorStartup(player: AVPlayer) {

        startupTask?.cancel()

        startupTask = Task {
            try? await Task.sleep(for: .seconds(15))

            guard !Task.isCancelled,
                  self.player === player else {
                return
            }

            if player.timeControlStatus != .playing {
                self.showPlaybackError()
            }
        }
    }

    private func showPlaybackError() {

        guard errorMessage.isEmpty else { return }

        errorMessage = "Contenido no disponible. Esta estación no se puede reproducir."

        player?.pause()
        isPlaying = false

        startupTask?.cancel()
        startupTask = nil
    }

    func pause() {
        startupTask?.cancel()
        startupTask = nil

        player?.pause()
        isPlaying = false
    }

    func resume() {
        guard let player = player else { return }

        errorMessage = ""
        player.play()
        monitorStartup(player: player)
    }

    func togglePlayback() {
        if isPlaying {
            pause()
        } else {
            resume()
        }
    }

    func stop() {

        startupTask?.cancel()
        startupTask = nil

        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil

        statusObserver?.invalidate()
        statusObserver = nil

        itemObserver?.invalidate()
        itemObserver = nil

        isPlaying = false

        try? AVAudioSession.sharedInstance().setActive(
            false,
            options: .notifyOthersOnDeactivation
        )
    }
}
