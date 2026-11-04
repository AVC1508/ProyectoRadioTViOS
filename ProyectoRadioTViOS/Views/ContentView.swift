import SwiftUI

struct ContentView: View {

    @State private var loginViewModel = LoginViewModel()

    var body: some View {

        @Bindable var login = loginViewModel

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

            if loginViewModel.isLoggedIn {

                VStack(spacing: 0) {

                    MainMenuView()

                    Button {
                        loginViewModel.logout()
                    } label: {
                        Text("CERRAR SESIÓN")
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.85))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                }

            } else {

                VStack(spacing: 25) {

                    Spacer()

                    Image(systemName: "dot.radiowaves.left.and.right")
                        .font(.system(size: 75))
                        .foregroundStyle(.cyan)

                    Text("Radio & TV")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.white)

                    Text("Tu entretenimiento en un solo lugar")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))

                    VStack(spacing: 18) {

                        TextField(
                            "",
                            text: $login.username,
                            prompt: Text("Usuario").foregroundColor(.gray)
                        )
                        .foregroundColor(.black)
                        .tint(.blue)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding()
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        SecureField(
                            "",
                            text: $login.password,
                            prompt: Text("Contraseña").foregroundColor(.gray)
                        )
                        .foregroundColor(.black)
                        .tint(.blue)
                        .padding()
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        if !login.errorMessage.isEmpty {
                            Text(login.errorMessage)
                                .foregroundStyle(.red)
                                .font(.footnote)
                        }

                        Button {
                            loginViewModel.login()
                        } label: {
                            Text("INICIAR SESIÓN")
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.cyan.opacity(0.85))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal, 30)

                    Spacer()

                    Text("PROYECTORADIOTVIOS")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.4))
                        .padding(.bottom, 20)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
