//
//  SecureKeychain.swift
//  FHKAuth
//
//  Created by Fredy Leon on 20/11/25.
//

import Security
import Foundation

public protocol SecureKeychainProtocol: Sendable {
    func save<T: Codable & Sendable>(_ value: T, for key: String) throws
    func read<T: Decodable & Sendable>(_ type: T.Type, for key: String) throws -> T?
    func delete(_ key: String) throws
    func contains(_ key: String) -> Bool
    func clearAll() throws
}

final public class SecureKeychain: SecureKeychainProtocol {
    static let shared = SecureKeychain()
    
    private let service = Bundle.main.bundleIdentifier ?? "com.yourapp"
    private let lock = NSLock()
    
    private init() {}
    
    public func save<T: Codable & Sendable>(_ value: T, for key: String) throws {
        lock.lock()
        defer { lock.unlock() }
        
        let data = try JSONEncoder().encode(value)
        try save(data: data, for: key)
    }
    
    public func read<T: Decodable & Sendable>(_ type: T.Type, for key: String) throws -> T? {
        lock.lock()
        defer { lock.unlock() }
        
        guard let data = try readData(for: key) else { return nil }
        return try JSONDecoder().decode(type, from: data)
    }
    
    public func delete(_ key: String) throws {
        lock.lock()
        defer { lock.unlock() }
        
        let query = baseQuery(for: key)
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KCError.from(status: status)
        }
    }
    
    public func contains(_ key: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        
        let query = baseQuery(for: key)
        return SecItemCopyMatching(query as CFDictionary, nil) == errSecSuccess
    }
    
    public func clearAll() throws {
        lock.lock()
        defer { lock.unlock() }
        
        for key in KeychainKey.allCases {
            try? delete(key.rawValue)
        }
    }
    
    public func atomicUpdate<T: Codable & Sendable>(_ key: String, update: (T?) -> T?) throws {
        lock.lock()
        defer { lock.unlock() }
        
        let current: T? = try read(T.self, for: key)
        if let updated = update(current) {
            try save(updated, for: key)
        } else {
            try delete(key)
        }
    }
}

// MARK: - Extension methods
private extension SecureKeychain {
    func save(data: Data, for key: String) throws {
        var query = baseQuery(for: key)
        query[kSecValueData as String] = data
        
        // Delete existing before save
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KCError.from(status: status)
        }
    }
    
    func readData(for key: String) throws -> Data? {
        var query = baseQuery(for: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        switch status {
        case errSecSuccess: return item as? Data
        case errSecItemNotFound: return nil
        default: throw KCError.from(status: status)
        }
    }
    
    func baseQuery(for key: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: service,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
    }
}
