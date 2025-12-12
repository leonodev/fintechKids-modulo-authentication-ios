//
//  KeychainStored.swift
//  FHKAuth
//
//  Created by Fredy Leon on 20/11/25.
//

@propertyWrapper
struct KeychainStored<T: Codable & Sendable>: Sendable {
    private let key: String
    
    init(_ key: KeychainKey) {
        self.key = key.rawValue
    }
    
    var wrappedValue: T? {
        get { try? SecureKeychain.shared.read(T.self, for: key) }
        set {
            do {
                if let value = newValue {
                    try SecureKeychain.shared.save(value, for: key)
                } else {
                    try SecureKeychain.shared.delete(key)
                }
            } catch {
                print("🔐 Keychain error: \(error)")
            }
        }
    }
}

@propertyWrapper
struct KeychainString: Sendable {
    private let key: String
    
    init(_ key: KeychainKey) {
        self.key = key.rawValue
    }
    
    var wrappedValue: String {
        get { (try? SecureKeychain.shared.read(String.self, for: key)) ?? "" }
        set { try? SecureKeychain.shared.save(newValue, for: key) }
    }
}

enum KeychainKey: String, CaseIterable, Sendable {
    case authToken
    case refreshToken
    case userCredentials
    case appSettings
    case biometricData
    case appLanguage
}
