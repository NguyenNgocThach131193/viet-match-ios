import AuthenticationServices
import CryptoKit
import Foundation

/// Utility that generates the nonce required for Apple Sign-In.
/// The nonce must be created before the request is sent to Apple and
/// its SHA-256 hash included in the request; the raw value is later
/// forwarded to Firebase together with the Apple idToken.
enum AppleSignInHelper {

    /// Generates a cryptographically secure random hex nonce.
    static func randomNonce(length: Int = 32) -> String {
        var randomBytes = [UInt8](repeating: 0, count: length)
        let result = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        precondition(result == errSecSuccess, "Unable to generate random bytes")
        return randomBytes.map { String(format: "%02x", $0) }.joined()
    }

    /// Returns the SHA-256 hex digest of a string.
    static func sha256(_ input: String) -> String {
        let hashed = SHA256.hash(data: Data(input.utf8))
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}
