import SwiftUI

struct AudioPlayerView: View {

    let station: RadioStation

    @State private var viewModel = AudioPlayerViewModel()

    var body: some View {

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

            VStack(spacing: 30) {

                Image(systemName: "radio")
                    .font(.system(size: 100))
                    .foregroundStyle(.cyan)

                Text(station.name)
                    .font(.title.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(station.displayGenre)
                    .foregroundStyle(.white.opacity(0.7))

                Text(station.displayCountry)
                    .foregroundStyle(.white.opacity(0.7))

                Button {
                    viewModel.togglePlayback()
                } label: {
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 35))
                        .foregroundStyle(.white)
                        .frame(width: 90, height: 90)
                        .background(Color.cyan)
                        .clipShape(Circle())
                }

                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Text(viewModel.isPlaying ? "Reproduciendo" : "Pausado")
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(30)
        }
        .navigationTitle("Reproductor")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let stream = station.streams?.first(where: {
                $0.works == true
            }) ?? station.streams?.first {
                viewModel.play(urlString: stream.url)
            } else {
                viewModel.errorMessage = "Esta estación no tiene una dirección de audio disponible."
            }
        }
        .onDisappear {
            viewModel.stop()
        }
    }
}
