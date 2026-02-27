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

public final class FHKSupabase: FHKSupabaseProtocol {
    // Properties computed injected
    private var languageManager: any FHKLanguageManagerProtocol { inject.languageManager }
    private var configManager: any FHKConfigurationProtocol { inject.configManager }
   
    private let servicesAPI: any ServicesAPIProtocol
    private let country: Countries

    public init(country: Countries) {
        self.servicesAPI = inject.servicesAPI
        self.country = country
    }
    
    func getSupabaseURL() async -> URL {
        let languageType = await languageManager.languageTypeFromCode(languageManager.selectedLanguage)
        let environment = await configManager.getEnvironment()
        
        do {
            let urlString = try servicesAPI.getURL(
                environment: environment,
                country: self.country,
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
                country: self.country,
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
    
    func parseSupabaseError(_ error: Error) -> FHKApiError? {
        guard let authError = error as? AuthError else { return nil }
        
        switch authError {
        case .api(let message, let errorCode, let data, let response):
            
            return FHKApiError(
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
