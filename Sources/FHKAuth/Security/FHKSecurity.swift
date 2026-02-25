//
//  FHKSecurity.swift
//  FHKAuth
//
//  Created by Fredy Leon on 16/2/26.
//

import Foundation
import CommonCrypto
import LocalAuthentication
import FHKDomain

public final class FHKSecurity: FHKSecurityProtocol {
    /// Paso 1.1: Generar una "SecuritySeed" única para cada usuario.
    /// Esto evita que dos contraseñas iguales generen el mismo hash.
    ///
    
    public init() {}
    
    public var biometryIcon: String {
        switch getBiometryType() {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        case .none: return ""
        }
    }
    
    public func generateSecuritySeed() -> Data? {
        var data = Data(count: 16)
        let status = data.withUnsafeMutableBytes { bytes in
            guard let baseAddress = bytes.baseAddress else { return Int32(errSecInternalComponent) }
            return SecRandomCopyBytes(kSecRandomDefault, 16, baseAddress)
        }
        
        return status == errSecSuccess ? data : nil
    }

    /// Paso 1.2: El motor de Hasheo (PBKDF2).
    /// Convierte la contraseña en algo ilegible.
    public func hashPassword(_ password: String, securitySeed: Data) -> String? {
        // 1. Desenvolvimiento seguro de los datos de la contraseña
        guard let passwordData = password.data(using: .utf8) else { return nil }
        
        var derivedKey = Data(count: 32)
        
        let status = derivedKey.withUnsafeMutableBytes { derivedKeyBytes in
            securitySeed.withUnsafeBytes { seedBytes in
                passwordData.withUnsafeBytes { passwordBytes in // También tratamos la pass como bytes
                    
                    // Usamos guard let para evitar el "!" en los baseAddress
                    guard let dKeyAddr = derivedKeyBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                          let seedAddr = seedBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                          let passAddr = passwordBytes.baseAddress?.assumingMemoryBound(to: UInt8.self)
                    else { return Int32(kCCMemoryFailure) }
                    
                    return CCKeyDerivationPBKDF(
                        CCPBKDFAlgorithm(kCCPBKDF2),
                        passAddr,           // We use the secure address
                        passwordData.count,
                        seedAddr,           // We use the secure address of the "seed"
                        securitySeed.count,
                        CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                        10000,
                        dKeyAddr,           // We used the secure exit route
                        32
                    )
                }
            }
        }
        
        return status == kCCSuccess ? derivedKey.base64EncodedString() : nil
    }
    
    public func getBiometryType() -> BiometryType {
        let context = LAContext()
        var error: NSError?
        
        // Verificamos si el hardware está disponible y configurado
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        // Una vez validado, preguntamos qué tipo específico es
        switch context.biometryType {
        case .faceID:
            return .faceID
            
        case .touchID:
            return .touchID
            
        default:
            return .none
        }
    }
}
