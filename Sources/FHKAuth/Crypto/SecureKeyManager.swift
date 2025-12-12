//
//  SecureKeyManager.swift
//  FHKAuth
//
//  Created by Fredy Leon on 11/12/25.
//

import Foundation
import CryptoKit
import FHKCore

public enum SecurityError: Error {
    case cryptoError(String)
    case invalidKeyData
}


final public class SecureKeyManager: Sendable {
    
    // Revert secret (XOR)
    private func deobfuscate(bytes: [UInt8], key: UInt8) -> [UInt8] {
        return bytes.map { $0 ^ key }
    }
    
    // get decrypted key
    public func getAnonKey() throws -> String {
        let xorKey = SecurityConstants.XOR_KEY
        
        // Des-ofuscar key Root
        let rootKeyBytes = deobfuscate(bytes: SecurityConstants.OBSCURED_KEY_BYTES, key: xorKey)
        let rootKey = SymmetricKey(data: rootKeyBytes)
        
        // Des-ofuscar the IV and the Tag
        let ivBytes = deobfuscate(bytes: SecurityConstants.OBSCURED_IV_BYTES, key: xorKey)
        let tagBytes = deobfuscate(bytes: SecurityConstants.OBSCURED_TAG_BYTES, key: xorKey)
        
        
        // Creating the CryptoKit Nonce (IV)
        guard let iv = try? AES.GCM.Nonce(data: ivBytes) else {
            throw SecurityError.cryptoError("Error to create Nonce/IV.")
        }
        
        // Create the SealedBox (encrypted body + deobfuscated tag)
        let sealedBox = try AES.GCM.SealedBox(
            nonce: iv,
            ciphertext: Data(SecurityConstants.ENCRYPTED_DATA_BYTES),
            tag: Data(tagBytes),
        )
                
        // Decrypt (Open with the Root Key)
        let decryptedData = try AES.GCM.open(sealedBox, using: rootKey)
                
        // Convert a key into plain text
        guard let anonKey = String(data: decryptedData, encoding: .utf8) else {
            throw SecurityError.cryptoError("Text decoding error.")
        }
        
        return anonKey
    }
    
}
