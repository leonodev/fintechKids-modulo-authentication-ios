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
    case invalidCredentials
    case userNotFound
    case emailNotConfirmed
    case otpExpired
    case tooManyRequests
    case authenticationNotImplemented
    case refreshSession
    case userAlreadyExist
    case unknown(String)

    public static func from(errorCode: String) -> AuthDomainError {
        switch errorCode {
        case "invalid_credentials":
            return .invalidCredentials
            
        case "user_not_found":
            return .userNotFound
            
        case "email_not_confirmed":
            return .emailNotConfirmed
            
        case "otp_expired":
            return .otpExpired
            
        case "too_many_requests":
            return .tooManyRequests
            
        // Register cases
        case "user_already_exists":
            return .userAlreadyExist
            
        default:
            return .unknown(errorCode)
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
