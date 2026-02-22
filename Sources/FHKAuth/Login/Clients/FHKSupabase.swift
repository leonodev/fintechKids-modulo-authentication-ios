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
import FHKConfig
import FHKInjections

public protocol FHKLanguageManagerProtocol: FHKInjectableProtocol {
    var selectedLanguage: String { get set }
    var currentBundle: Bundle { get }
    func changeLanguage(to language: String)
    func languageTypeFromCode(_ string: String) -> LanguageType
}

public protocol FHKSupabaseProtocol: FHKInjectableProtocol {
    func loginUser(email: String, password: String) async throws -> AuthResponseProtocol
    func logoutUser() async throws
    func refreshSession() async throws -> AuthResponseProtocol
    func registerUser(email: String, password: String) async throws -> AuthResponse
    func setSession(accessToken: String) async throws

    // MARK: - User Data
    var isUserAuthenticated: Bool { get }
    var client: SupabaseClient { get }
}

public final class FHKSupabase: FHKSupabaseProtocol {
    // Properties injected
    private let servicesAPI: any ServicesAPIProtocol
    private let supabaseURL: URL
    
    // Injections Dependency
    private let languageManager = inject.languageManager
    private let configManager = inject.configManager
    
    public init() {
        let api = inject.servicesAPI
        self.servicesAPI = api
        
        do {
            let languageSelected = languageManager.selectedLanguage
            let languageType = languageManager.languageTypeFromCode(languageSelected)
            let environmentType = configManager.getEnvironment()
            
            let urlString = try api.getURL(environment: configManager.getEnvironment(),
                                           language: languageType,
                                           serviceKey: .supabase)
            guard let validURL = URL(string: urlString) else {
                fatalError("FHK Error: Supabase URL is not valid")
            }
            self.supabaseURL = validURL
            
        } catch {
            fatalError("FHK Error: Could not fetch URL from ServicesAPI")
        }
    }

    // MARK: - Login Authentication
    public func loginUser(email: String, password: String) async throws -> AuthResponseProtocol {
        
        do {
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
        try await client.auth.signOut()
    }

    public func refreshSession() async throws -> AuthResponseProtocol {
        let session = try await client.auth.refreshSession()
        return SupabaseAuthResponse(session: session)
    }

    public var isUserAuthenticated: Bool {
        return client.auth.currentUser != nil
    }
    
    public func setSession(accessToken: String) async throws {
        // Supabase necesita un Access Token para considerar que la sesión es válida.
        // El Refresh Token se puede dejar vacío si solo quieres rehidratar la sesión actual.
        try await client.auth.setSession(accessToken: accessToken, refreshToken: "")
    }
}

public extension FHKSupabase {
    
    public var client: SupabaseClient {
        do {
            let anonKey = try SecureKeyManager().getAnonKey()
            return SupabaseClient(supabaseURL: self.supabaseURL, supabaseKey: anonKey)
        } catch {
            fatalError("FHK Error: Could not get Anon Key")
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
