//
//  SupabaseAuth.swift
//  FHKAuth
//
//  Created by Fredy Leon on 12/1/26.
//

import Foundation
import Supabase
import PostgREST
import FHKDomain
import FHKUtils

public final class FHKSupabase: FHKAuthProtocol, FHKSupabaseErrorProtocol {
    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }
    
    public func login(loginEntity: LoginEntity) async throws -> FHKUserSession {
        do {
            let session = try await client.auth.signIn(email: loginEntity.email,
                                                       password: loginEntity.password)
            let pin = try await fetchAprovedPin(parentEmail: loginEntity.email)
            return session.toDomain(pinApprove: pin)
        } catch {
            throw handleAuthError(error, context: loginEntity.toSafeLogString())
        }
    }

    public func register(registerEntity: RegisterUserEntity) async throws -> FHKUserSession {
        do {
            let signUp = try await client.auth.signUp(
                email: registerEntity.email,
                password: registerEntity.password
            )
            
            let familyData: [String: String] = [
                DB.TABLE_FAMILIES.COLUMN.emailParent: registerEntity.email,
                DB.TABLE_FAMILIES.COLUMN.nameFamily: registerEntity.familyName.lowercased(),
                DB.TABLE_FAMILIES.COLUMN.approvePin: registerEntity.approvePIN
            ]
    
            try await client
                .from(DB.TABLE_FAMILIES.NAME)
                .insert(familyData)
                .execute()
            
            return try signUp.toDomain(pinApprove: registerEntity.approvePIN)
            
        } catch {
            throw handleAuthError(error, context: registerEntity.toSafeLogString())
        }
    }
    
    public func logout() async throws {
        try await client.auth.signOut()
    }
    
    public func refreshSession(emailParent: String) async throws -> FHKUserSession {
        let session = try await client.auth.refreshSession()
        let pin = try await fetchAprovedPin(parentEmail: emailParent)
        return session.toDomain(pinApprove: pin)
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

// MARK: Private Methods
private extension FHKSupabase {
    
    func fetchAprovedPin(parentEmail: String) async throws -> String {
        do {
            let result: FamilyPinResponse = try await client
                .from(DB.TABLE_FAMILIES.NAME)
                .select(DB.TABLE_FAMILIES.COLUMN.approvePin)
                .eq(DB.TABLE_FAMILIES.COLUMN.emailParent, value: parentEmail)
                .single()
                .execute()
                .value
            
            return result.approve_pin
        } catch {
            throw FHKSupabaseError.unknown(error.localizedDescription)
        }
    }
}

// MARK: Handle Errors
private extension FHKSupabase {
    
    func handleAuthError(_ error: Error, context: String? = nil) -> Error {
        if let authError = error as? AuthError {
            return mapToDomainError(authError, context: context)
        }
        
        if let authError = error as? PostgrestError {
            let errorPostgres = mapPostgresError(authError.code ?? "", message: context ?? "")
            return errorPostgres
        }
        return FHKSupabaseError.unknown(error.localizedDescription)
    }
    
    func mapToDomainError(_ error: AuthError, context: String?) -> FHKSupabaseError {
        
        switch error {
        case .api(_, let errorCode, _, _):
            let baseError = FHKSupabaseError.from(errorCode: errorCode.rawValue)
            
            if case .invalidCredentials = baseError {
                return .invalidCredentials(context: context)
            }
            if case .userAlreadyExists = baseError {
                return .userAlreadyExists(context: context)
            }
            
            return baseError
        default:
            return .unknown(error.localizedDescription)
        }
    }
}


struct FamilyPinResponse: Decodable {
    let approve_pin: String
}
