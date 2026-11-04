import SwiftUI

struct MainMenuView: View {

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

                VStack(spacing: 30) {

                    Image(systemName: "dot.radiowaves.left.and.right")
                        .font(.system(size: 75))
                        .foregroundStyle(.cyan)

                    Text("Radio & TV")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)

                    Text("Selecciona una opción")
                        .foregroundStyle(.white.opacity(0.7))

                    NavigationLink {
                        RadioListView()
                    } label: {
                        menuButton(
                            title: "RADIO",
                            subtitle: "Escucha tus estaciones favoritas",
                            icon: "radio"
                        )
                    }

                    NavigationLink {
                        TVListView()
                    } label: {
                        menuButton(
                            title: "TELEVISIÓN",
                            subtitle: "Disfruta canales en vivo",
                            icon: "tv"
                        )
                    }
                }
                .padding(30)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func menuButton(
        title: String,
        subtitle: String,
        icon: String
    ) -> some View {

        HStack(spacing: 18) {
            Image(systemName: icon)
                .font(.system(size: 35))
                .foregroundStyle(.cyan)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline.bold())
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    MainMenuView()
}
