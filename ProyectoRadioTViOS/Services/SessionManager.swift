import Foundation
import Security

class SessionManager {

    private let service = "com.proyectoradiotv.session"
    private let account = "userSession"

    // Guardar la sesión en Keychain
    func saveSession() -> Bool {

        clearSession()

        let data = Data("active".utf8)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]

        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }

    // Comprobar si existe una sesión
    func hasSession() -> Bool {

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?

        let status = SecItemCopyMatching(
            query as CFDictionary,
            &result
        )

        if status == errSecSuccess,
           let data = result as? Data,
           let session = String(data: data, encoding: .utf8) {
            return session == "active"
        }

        return false
    }

    // Eliminar la sesión
    func clearSession() {

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        SecItemDelete(query as CFDictionary)
    }
}
