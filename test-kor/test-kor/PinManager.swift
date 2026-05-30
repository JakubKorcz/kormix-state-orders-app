import Foundation
import CryptoKit

enum PinManager {
    private static let pinHashKey = "app_pin_hash"
    private static let defaults = UserDefaults.standard

    static var isPinSet: Bool {
        defaults.string(forKey: pinHashKey) != nil
    }

    static func storePin(_ pin: String) {
        defaults.set(hash(pin), forKey: pinHashKey)
    }

    static func verifyPin(_ pin: String) -> Bool {
        guard let storedHash = defaults.string(forKey: pinHashKey) else { return false }
        return hash(pin) == storedHash
    }

    static func removePin() {
        defaults.removeObject(forKey: pinHashKey)
    }

    static func changePin(from oldPin: String, to newPin: String) -> Bool {
        guard verifyPin(oldPin) else { return false }
        storePin(newPin)
        return true
    }

    private static func hash(_ pin: String) -> String {
        let data = Data(pin.utf8)
        let digest = SHA256.hash(data: data)
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }
}
