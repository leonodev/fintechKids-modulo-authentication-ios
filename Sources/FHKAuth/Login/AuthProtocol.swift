//
//  AuthProtocol.swift
//  FHKAuth
//
//  Created by Fredy Leon on 10/12/25.
//

import Foundation
import Supabase
import FHKUtils

public enum AuthDomainError: Error {
    case invalidResponseType
    case authenticationFailed(Error)
    case mappingError(String)
    case authenticationNotImpemented
}

public protocol AuthProtocol: Sendable {
    associatedtype AuthResponse: Decodable & Sendable
    
    // MARK: - Core Authentication
    func loginUser(email: String, password: String) async throws -> AuthResponse
    func logoutUser() async throws
    func refreshSession() async throws -> AuthResponse

    // MARK: - User Data
    var isUserAuthenticated: Bool { get }
}


final class SupabaseAuth: AuthProtocol {
    // We specify the specific type of response for this service
    typealias AuthResponse = SupabaseAuthResponse
    private let supabaseClient: SupabaseClient? = getSecureSupabaseClient()

    // MARK: - Core Authentication
    func loginUser(email: String, password: String) async throws -> SupabaseAuthResponse {
        
        guard let session = try await supabaseClient?.auth.signIn(email: email, password: password) else {
             throw AuthDomainError.authenticationFailed(NSError(domain: "Supabase",
                                                                code: 0,
                                                                userInfo: [NSLocalizedDescriptionKey: "Sign-In successful but session data is missing."]))
        }
        
        let authResponse = SupabaseAuthResponse(session: session)
        return authResponse
    }
    
    func logoutUser() async throws {
        try await supabaseClient?.auth.signOut()
    }
    
    func refreshSession() async throws -> SupabaseAuthResponse {
        // Supabase handles the refresh with the stored token.
        let session = try await supabaseClient?.auth.refreshSession()
        let jsonResponseData = try JSONEncoder().encode(session)
        let authResponse = try JSONDecoder().decode(SupabaseAuthResponse.self, from: jsonResponseData)
        return authResponse
    }
    
    var isUserAuthenticated: Bool {
        return supabaseClient?.auth.currentUser != nil
    }
    
    private static func getSecureSupabaseClient() -> SupabaseClient? {
        let SUPABASE_BASE_URL = "https://chaukyiczbxkkbnxgahi.supabase.co"
        
        do {
            // Call the manager to get the decrypted key
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
}


public enum AuthPlatform {
    case supabase
    case firebase
}

public protocol AuthServiceFactory: Sendable {
    func makeAuthService(for platform: AuthPlatform) throws -> any AuthProtocol
}

public final class DefaultAuthServiceFactory: AuthServiceFactory {
    public init(){}
    public func makeAuthService(for platform: AuthPlatform) throws -> any AuthProtocol {
        
        switch platform {
        case .supabase:
            return SupabaseAuth()
            
        case .firebase:
            throw AuthDomainError.authenticationNotImpemented
        }
    }
}


public actor Login {
    private let factory: any AuthServiceFactory
    public var isAuthenticated: Bool = false
    
    public init(factory: any AuthServiceFactory) {
        self.factory = factory
    }
    
    public func loginUser(platform: AuthPlatform, email: String, password: String) async throws {
        let loginMethod = try factory.makeAuthService(for: platform)
        let response = try await loginMethod.loginUser(email: email, password: password)
        
        guard let authResponse = response as? SupabaseAuthResponse else {
            throw AuthDomainError.invalidResponseType
        }
        
        self.isAuthenticated = authResponse.accessToken != nil
    }
}
