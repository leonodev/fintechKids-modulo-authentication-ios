//
//  SupabaseAuth.swift
//  FHKAuth
//
//  Created by Fredy Leon on 12/1/26.
//

import Foundation
import Supabase
import FHKDomain

public final class FHKSupabase: FHKAuthProtocol {
    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }
    
    public func login(email: String, password: String) async throws -> FHKUserSession {
        do {
            let session = try await client.auth.signIn(email: email, password: password)
            return session.toDomain()
        } catch {
            throw handleAuthError(error)
        }
    }

    public func register(email: String, password: String) async throws -> FHKUserSession {
        do {
            let operation = try await client.auth.signUp(
                email: email,
                password: password
            )
            
            return try operation.toDomain()
            
        } catch {
            throw handleAuthError(error)
        }
    }
    
    public func logout() async throws {
        try await client.auth.signOut()
    }
    
    public func refreshSession() async throws -> FHKUserSession {
        let session = try await client.auth.refreshSession()
        return session.toDomain()
    }

    public var isUserAuthenticated: Bool {
        get async {
            return client.auth.currentUser != nil
        }
    }
    
    public func setSession(accessToken: String) async throws {
        try await client.auth.setSession(accessToken: accessToken, refreshToken: "")
    }  
}

private extension FHKSupabase {
    
    func handleAuthError(_ error: Error) -> Error {
        if let authError = error as? AuthError {
            return mapToDomainError(authError)
        }
        return FHKDomainError.unknown(error.localizedDescription)
    }
    
    func mapToDomainError(_ error: AuthError) -> FHKDomainError {
        switch error {
        case .api(_, let errorCode, _, _):
            return FHKDomainError.from(errorCode: errorCode.rawValue)
        default:
            return .unknown(error.localizedDescription)
        }
    }
}
