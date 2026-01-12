//
//  SupabaseAuthResponse.swift
//  FHKAuth
//
//  Created by Fredy Leon on 11/12/25.
//

import Foundation
import Supabase

public protocol AuthResponseProtocol: Sendable {
    var accessToken: String? { get }
    var userID: String { get }
}

public enum AuthDomainError: Error {
    case clientAuthInvalid
    case invalidCredentials
    case authenticationNotImplemented
    case refreshSession
    case unknown(String)

    public static func from(errorCode: String) -> AuthDomainError {
        switch errorCode {
        case "invalid_credentials":
            return .invalidCredentials
            
        default:
            return .unknown(errorCode)
        }
    }

    // Propiedad calculada para el mensaje de la UI
    public var userMessage: String {
        switch self {
        case .clientAuthInvalid:
            return "clientAuthInvalid."
            
        case .invalidCredentials:
            return "El correo o la contraseña son incorrectos."
            
        case .authenticationNotImplemented:
            return "Este método de inicio de sesión no está disponible."
            
        case .refreshSession:
            return "Tu sesión ha expirado. Por favor, ingresa de nuevo."
            
        case .unknown(let code):
            return "Ocurrió un error inesperado (\(code))."
        }
    }
}

public struct SupabaseAuthResponse: Sendable, AuthResponseProtocol {
    public let accessToken: String?
    public let refreshToken: String?
    public let userID: String
    public let email: String

    public let expiresIn: Double
    public let expiresAt: Double

    /// Inicializador que transforma el objeto 'Session' del SDK de Supabase
    /// en nuestro modelo interno.
    public init(session: Session) {
        self.accessToken = session.accessToken
        self.refreshToken = session.refreshToken
        self.expiresIn = session.expiresIn
        self.expiresAt = session.expiresAt
        
        // Extraemos datos del objeto User de Supabase
        self.userID = session.user.id.uuidString
        self.email = session.user.email ?? ""
    }
}
