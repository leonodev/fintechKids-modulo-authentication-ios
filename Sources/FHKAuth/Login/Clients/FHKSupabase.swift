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
    func getClient() async throws -> SupabaseClient

    // MARK: - User Data
    var isUserAuthenticated: Bool { get async }
}

public final class FHKSupabase: FHKSupabaseProtocol {
   
    private let servicesAPI: any ServicesAPIProtocol
    //private let supabaseURL: URL
    
    //  // Properties injected safe
    private var languageManager: any FHKLanguageManagerProtocol { inject.languageManager }
    private var configManager: any FHKConfigurationProtocol { inject.configManager }
    
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
    
//    public init() {
//        let api = inject.servicesAPI
//        self.servicesAPI = api
//        
//        let currentLanguageManager = inject.languageManager
//        let currentConfigManager = inject.configManager
//        
//        do {
//            let languageSelected = currentLanguageManager.selectedLanguage
//            let languageType = currentLanguageManager.languageTypeFromCode(languageSelected)
//            let environmentType = currentConfigManager.getEnvironment()
//            
//            let urlString = try api.getURL(environment: currentConfigManager.getEnvironment(),
//                                           language: languageType,
//                                           serviceKey: .supabase)
//            guard let validURL = URL(string: urlString) else {
//                fatalError("FHK Error: Supabase URL is not valid")
//            }
//            self.supabaseURL = validURL
//            
//        } catch {
//            fatalError("FHK Error: Could not fetch URL from ServicesAPI")
//        }
//    }

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
        // Supabase necesita un Access Token para considerar que la sesión es válida.
        // El Refresh Token se puede dejar vacío si solo quieres rehidratar la sesión actual.
        try await getClient().auth.setSession(accessToken: accessToken, refreshToken: "")
    }
}

public extension FHKSupabase {
    
//    public var client: SupabaseClient {
//        do {
//            let anonKey = try SecureKeyManager().getAnonKey()
//            return SupabaseClient(supabaseURL: self.getSupabaseURL(), supabaseKey: anonKey)
//        } catch {
//            fatalError("FHK Error: Could not get Anon Key")
//        }
//    }
    
    func getClient() async throws -> SupabaseClient {
        
        // Pedimos los datos al MainActor (donde vive el LanguageManager)
        // Solo "saltamos" al hilo principal para leer estas 2 variables
        let (langCode, env) = await MainActor.run {
            return (languageManager.selectedLanguage, configManager.getEnvironment())
        }
        
        let languageType = await MainActor.run {
            languageManager.languageTypeFromCode(langCode)
        }
        
        // Volvemos automáticamente al hilo de fondo para el resto
        let urlString = try servicesAPI.getURL(
            environment: env,
            language: languageType,
            serviceKey: .supabase
        )
        
        let anonKey = try SecureKeyManager().getAnonKey()
        return SupabaseClient(supabaseURL: URL(string: urlString)!, supabaseKey: anonKey)
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
