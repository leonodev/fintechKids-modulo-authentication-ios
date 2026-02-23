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

public protocol FHKSupabaseProtocol: FHKInjectableProtocol {
    func loginUser(email: String, password: String) async throws -> AuthResponseProtocol
    func logoutUser() async throws
    func refreshSession() async throws -> AuthResponseProtocol
    func registerUser(email: String, password: String) async throws -> AuthResponse
    func setSession(accessToken: String) async throws
    func getClient() -> SupabaseClient

    // MARK: - User Data
    var isUserAuthenticated: Bool { get async }
}

public final class FHKSupabase: FHKSupabaseProtocol {
    //  // Properties computed injected safe
    private var languageManager: any FHKLanguageManagerProtocol { inject.languageManager }
    private var configManager: any FHKConfigurationProtocol { inject.configManager }
   
    private let servicesAPI: any ServicesAPIProtocol

    public init() {
        self.servicesAPI = inject.servicesAPI
    }
    
    func getSupabaseURL() async -> URL {
        let languageType = await languageManager.languageTypeFromCode(languageManager.selectedLanguage)
        let environment = await configManager.getEnvironment()
        
        do {
            let urlString = try servicesAPI.getURL(
                environment: environment,
                language: languageType,
                serviceKey: .supabase
            )
            return URL(string: urlString)!
        } catch {
            fatalError("FHK Error: Could not fetch URL")
        }
    }

    // MARK: - Login Authentication
    public func loginUser(email: String, password: String) async throws -> AuthResponseProtocol {
        
        do {
            let session = try await getClient().auth.signIn(email: email, password: password)
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
            let operation = try await getClient().auth.signUp(
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
        try await getClient().auth.signOut()
    }

    public func refreshSession() async throws -> AuthResponseProtocol {
        let session = try await getClient().auth.refreshSession()
        return SupabaseAuthResponse(session: session)
    }

    public var isUserAuthenticated: Bool {
        get async {
            do {
                let client = try await getClient()
                return client.auth.currentUser != nil
            } catch {
                return false
            }
        }
    }
    
    public func setSession(accessToken: String) async throws {
        try await getClient().auth.setSession(accessToken: accessToken, refreshToken: "")
    }
}

public extension FHKSupabase {

    func getClient() -> SupabaseClient {
        let (langCode, env) = (languageManager.selectedLanguage, configManager.getEnvironment())
        let languageType = languageManager.languageTypeFromCode(langCode)
        
        do {
            let urlString = try servicesAPI.getURL(
                environment: env,
                language: languageType,
                serviceKey: .supabase)
            
            let anonKey = try SecureKeyManager().getAnonKey()
            
            guard let url = URL(string: urlString) else {
                fatalError("Supabase URL inválida: \(urlString)")
            }
            
            return SupabaseClient(supabaseURL: url, supabaseKey: anonKey)
            
        } catch let error as APIConfigError {
            fatalError("Error configuration de API: \(error)")
            
        } catch let error as SecurityError {
            fatalError("Error getting AnonKey: \(error)")
            
        } catch {
            fatalError("Error unexpected creating Supabase client: \(error)")
        }
    }
    
    func parseSupabaseError(_ error: Error) -> SupabaseApiError? {
        guard let authError = error as? AuthError else { return nil }
        
        switch authError {
        case .api(let message, let errorCode, let data, let response):
            
            return SupabaseApiError(
                code: response.statusCode,
                errorCode: errorCode.rawValue,
                msg: message
            )
            
        default:
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
