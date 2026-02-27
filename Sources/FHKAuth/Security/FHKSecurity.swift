//
//  FHKSecurity.swift
//  FHKAuth
//
//  Created by Fredy Leon on 16/2/26.
//

import Foundation
import CommonCrypto
import CryptoKit
import LocalAuthentication
import FHKDomain

public final class FHKSecurity: FHKSecurityProtocol {
    /// Generate a unique "SecuritySeed" for each user.
    /// This prevents two identical passwords from generating the same hash.
 
    public init() {}
    
    public var biometryIcon: String {
        switch getBiometryType() {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        case .none: return ""
        }
    }
    
    public func getBiometryType() -> BiometryType {
        let context = LAContext()
        var error: NSError?
        
        // We check if the hardware is available and configured
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        // Once validated, we ask what specific type it is
        switch context.biometryType {
        case .faceID:
            return .faceID
            
        case .touchID:
            return .touchID
            
        default:
            return .none
        }
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

private extension FHKSecurity {
    // Revert secret (XOR)
    private func deobfuscate(bytes: [UInt8], key: UInt8) -> [UInt8] {
        return bytes.map { $0 ^ key }
    }
}
