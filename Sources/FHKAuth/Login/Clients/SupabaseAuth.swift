//
//  SupabaseAuth.swift
//  FHKAuth
//
//  Created by Fredy Leon on 12/1/26.
//

import Foundation
import Supabase
import FHKUtils
import FHKCore

public protocol AuthProtocol: Sendable {
    func loginUser(email: String, password: String) async throws -> AuthResponseProtocol
    func logoutUser() async throws
    func refreshSession() async throws -> AuthResponseProtocol
    func registerUser(email: String, password: String) async throws -> AuthResponse
    func setSession(accessToken: String) async throws

    // MARK: - User Data
    var isUserAuthenticated: Bool { get }
}

public final class SupabaseAuth: AuthProtocol {
    private let supabaseClient: SupabaseClient? = getSecureSupabaseClient()

    // MARK: - Login Authentication
    public func loginUser(email: String, password: String) async throws -> AuthResponseProtocol {
        
        do {
            guard let client = supabaseClient else {
                throw FHKDomainError.authenticationNotImplemented
            }
            
            let session = try await client.auth.signIn(email: email, password: password)
            return SupabaseAuthResponse(session: session)
        } catch {
            
            if let authError = error as? AuthError {
                throw mapToDomainError(authError)
            }
            
            throw FHKDomainError.unknown(error.localizedDescription)
        }
    }
    
    // MARK: - Registration
    public func registerUser(email: String, password: String) async throws -> AuthResponse {
        do {
            guard let client = supabaseClient else {
                throw FHKDomainError.authenticationNotImplemented
            }
            
            let operation = try await client.auth.signUp(
                email: email,
                password: password
            )
            
            return operation
            
        } catch {
            if let authError = error as? AuthError {
                throw mapToDomainError(authError)
            }
            
            throw FHKDomainError.unknown(error.localizedDescription)
        }
    }
    
    public func logoutUser() async throws {
        try await supabaseClient?.auth.signOut()
    }

    public func refreshSession() async throws -> AuthResponseProtocol {
        guard let session = try await supabaseClient?.auth.refreshSession() else {
            throw FHKDomainError.refreshSession
        }

        return SupabaseAuthResponse(session: session)
    }

    public var isUserAuthenticated: Bool {
        return supabaseClient?.auth.currentUser != nil
    }
    
    public func setSession(accessToken: String) async throws {
        guard let client = supabaseClient else {
            throw FHKDomainError.authenticationNotImplemented
        }
        
        // Supabase necesita un Access Token para considerar que la sesión es válida.
        // El Refresh Token se puede dejar vacío si solo quieres rehidratar la sesión actual.
        try await client.auth.setSession(accessToken: accessToken, refreshToken: "")
    }
}

extension SupabaseAuth {
    
    public static func getSecureSupabaseClient() -> SupabaseClient? {
        do {
            let SUPABASE_BASE_URL = try ServicesAPI.getURL(serviceKey: .supabase)
            let anonKey = try SecureKeyManager().getAnonKey()
            
            guard let url = URL(string: SUPABASE_BASE_URL) else {
                Logger.error("Invalid Supabase URL.")
                return nil
            }
            
            return SupabaseClient(supabaseURL: url, supabaseKey: anonKey)
            
        } catch {
            Logger.error("SupabaseAuth could not be initialized. Error decrypting the key: \(error)")
            return nil
        }
    }
    
    func parseSupabaseError(_ error: Error) -> SupabaseApiError? {
        guard let authError = error as? AuthError else { return nil }
        
        switch authError {
            // API is in the client's auth response
        case .api(let message, let errorCode, let data, let response):
            
            return SupabaseApiError(
                code: response.statusCode,
                errorCode: errorCode.rawValue,
                msg: message
            )
            
        default:
            // Handling other cases such as .unknown, .mock, etc.
            return nil
        }
    }
    
    func mapToDomainError(_ error: AuthError) -> FHKDomainError {
        switch error {
        case .api(_, let errorCode, _, _):
            // We extract the rawValue and use the mapper
            return FHKDomainError.from(errorCode: errorCode.rawValue)
        default:
            return .unknown(error.localizedDescription)
        }
    }
}
