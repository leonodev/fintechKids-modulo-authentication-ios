//
//  SupabaseAuth.swift
//  FHKAuth
//
//  Created by Fredy Leon on 12/1/26.
//

import Foundation
import Supabase
import FHKInjections
import FHKDomain

public final class FHKSupabase: FHKAuthProtocol {
    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }
    
    // MARK: - Login Authentication
    public func login(email: String, password: String) async throws -> FHKUserSession {
        do {
            let session = try await client.auth.signIn(email: email, password: password)
            return session.toDomain()
        } catch {
            throw handleAuthError(error)
        }
    }

    // MARK: - Registration
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

//public final class FHKSupabase: FHKAuthProtocol {
// 
//    // Properties computed injected
//    private var languageManager: any FHKLanguageManagerProtocol { inject.languageManager }
//    private var configManager: any FHKConfigurationProtocol { inject.configManager }
//   
//    private let servicesAPI: any ServicesAPIProtocol
//    private let country: Countries
//
//    public init(country: Countries) {
//        self.servicesAPI = inject.servicesAPI
//        self.country = country
//    }
//    
//    func getSupabaseURL() async -> URL {
//        let languageType = await languageManager.languageTypeFromCode(languageManager.selectedLanguage)
//        let environment = await configManager.getEnvironment()
//        
//        do {
//            let urlString = try servicesAPI.getURL(
//                environment: environment,
//                country: self.country,
//                serviceKey: .supabase
//            )
//            return URL(string: urlString)!
//        } catch {
//            fatalError("FHK Error: Could not fetch URL")
//        }
//    }
//
//    // MARK: - Login Authentication
//    public func login(email: String, password: String) async throws -> FHKUserSession {
//        do {
//            let session = try await getClient().auth.signIn(email: email, password: password)
//            return try session.toDomain()
//        } catch {
//            if let authError = error as? AuthError {
//                throw mapToDomainError(authError)
//            }
//            
//            throw FHKDomainError.unknown(error.localizedDescription)
//        }
//    }
//    
//    // MARK: - Registration
//    public func register(email: String, password: String) async throws -> FHKUserSession {
//        do {
//            let operation = try await getClient().auth.signUp(
//                email: email,
//                password: password
//            )
//            
//            return try operation.toDomain()
//            
//        } catch {
//            if let authError = error as? AuthError {
//                throw mapToDomainError(authError)
//            }
//            
//            throw FHKDomainError.unknown(error.localizedDescription)
//        }
//    }
//    
//    public func logout() async throws {
//        try await getClient().auth.signOut()
//    }
//
//    public func refreshSession() async throws -> FHKUserSession {
//        let session = try await getClient().auth.refreshSession()
//        return session.toDomain()
//    }
//
//    public var isUserAuthenticated: Bool {
//        get async {
//            do {
//                let client = try await getClient()
//                return client.auth.currentUser != nil
//            } catch {
//                return false
//            }
//        }
//    }
//    
//    public func setSession(accessToken: String) async throws {
//        try await getClient().auth.setSession(accessToken: accessToken, refreshToken: "")
//    }
//}
//
//public extension FHKSupabase {
//
//    func getClient() -> SupabaseClient {
//        let (langCode, env) = (languageManager.selectedLanguage, configManager.getEnvironment())
//        let languageType = languageManager.languageTypeFromCode(langCode)
//        
//        do {
//            let urlString = try servicesAPI.getURL(
//                environment: env,
//                country: self.country,
//                serviceKey: .supabase)
//            
//            let anonKey = try SecureKeyManager().getAnonKey()
//            
//            guard let url = URL(string: urlString) else {
//                fatalError("Supabase URL inválida: \(urlString)")
//            }
//            
//            return SupabaseClient(supabaseURL: url, supabaseKey: anonKey)
//            
//        } catch let error as APIConfigError {
//            fatalError("Error configuration de API: \(error)")
//            
//        } catch let error as SecurityError {
//            fatalError("Error getting AnonKey: \(error)")
//            
//        } catch {
//            fatalError("Error unexpected creating Supabase client: \(error)")
//        }
//    }
//    
//    func parseSupabaseError(_ error: Error) -> FHKApiError? {
//        guard let authError = error as? AuthError else { return nil }
//        
//        switch authError {
//        case .api(let message, let errorCode, let data, let response):
//            
//            return FHKApiError(
//                code: response.statusCode,
//                errorCode: errorCode.rawValue,
//                msg: message
//            )
//            
//        default:
//            return nil
//        }
//    }
//    
//    func mapToDomainError(_ error: AuthError) -> FHKDomainError {
//        switch error {
//        case .api(_, let errorCode, _, _):
//            // We extract the rawValue and use the mapper
//            return FHKDomainError.from(errorCode: errorCode.rawValue)
//        default:
//            return .unknown(error.localizedDescription)
//        }
//    }
//}
