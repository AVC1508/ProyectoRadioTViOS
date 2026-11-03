import Foundation
import Observation

@MainActor
@Observable
class LoginViewModel {

    var username = ""
    var password = ""
    var errorMessage = ""

    private(set) var isLoggedIn = false

    private let validUsername = "radio"
    private let validPassword = "1234"

    private let sessionManager = SessionManager()

    // Comprobar si ya existe una sesión guardada
    init() {
        isLoggedIn = sessionManager.hasSession()
    }

    // Validar las credenciales
    func login() {

        if username == validUsername && password == validPassword {

            if sessionManager.saveSession() {
                isLoggedIn = true
                errorMessage = ""
                password = ""
            } else {
                errorMessage = "No se pudo guardar la sesión."
            }

        } else {
            errorMessage = "Usuario o contraseña incorrectos."
        }
    }

    // Cerrar sesión
    func logout() {
        sessionManager.clearSession()
        isLoggedIn = false
        username = ""
        password = ""
        errorMessage = ""
    }
}
