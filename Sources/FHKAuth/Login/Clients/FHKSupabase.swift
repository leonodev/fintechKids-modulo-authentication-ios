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

    public func register(email: String, password: String, familyName: String) async throws -> FHKUserSession {
        do {
            let signUp = try await client.auth.signUp(
                email: email,
                password: password
            )
            
            let familyData: [String: String] = [
                DB.TABLE_FAMILIES.COLUMN.emailParent: email,
                DB.TABLE_FAMILIES.COLUMN.nameFamily: familyName.lowercased()
            ]
    
            try await client
                .from(DB.TABLE_FAMILIES.NAME)
                .insert(familyData)
                .execute()
            
            return try signUp.toDomain()
            
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
        return FHKSupabaseError.unknown(error.localizedDescription)
    }
    
    func mapToDomainError(_ error: AuthError) -> FHKSupabaseError {
        switch error {
        case .api(_, let errorCode, _, _):
            return FHKSupabaseError.from(errorCode: errorCode.rawValue)
        default:
            return .unknown(error.localizedDescription)
        }
    }
}
