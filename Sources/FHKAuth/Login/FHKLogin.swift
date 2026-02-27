//
//  AuthProtocol.swift
//  FHKAuth
//
//  Created by Fredy Leon on 10/12/25.
//

import FHKDomain

public final class DefaultAuthServiceFactory: AuthServiceFactory {
    public init(){}
    
    public func makeAuthService(for platform: AuthPlatform, country: Countries) throws -> any FHKAuthProtocol {
        
        switch platform {
        case .supabase:
            return FHKSupabase(country: country)
            
        case .firebase:
            throw FHKDomainError.authenticationNotImplemented
        }
    }
}


public actor Login {
    
    private let factory: any AuthServiceFactory
    private let country: Countries
    public var isAuthenticated: Bool = false
    
    public init(factory: any AuthServiceFactory, country: Countries) {
        self.factory = factory
        self.country = country
    }
    
    public func loginUser(platform: AuthPlatform, email: String, password: String) async throws -> String {
        let service = try factory.makeAuthService(for: platform, country: self.country)
        
        let response = try await service.login(email: email, password: password)
        self.isAuthenticated = response.accessToken != nil
        
        guard let token = response.accessToken else {
            throw FHKDomainError.accessToken
        }
        
        return token
    }
    
    public func registerUser(platform: AuthPlatform, email: String, password: String) async throws {
        let service = try factory.makeAuthService(for: platform, country: self.country)
       
        let response = try await service.register(email: email, password: password)
        
        self.isAuthenticated = response.hasActiveSession
        
        if !response.hasActiveSession {
            print("El usuario se creó, pero debe confirmar su email para tener una sesión activa")
        }
    }
    
    public func restoreSession(platform: AuthPlatform, token: String) async throws {
        let service = try factory.makeAuthService(for: platform, country: self.country)
        
        // Llamamos al nuevo método que acabamos de crear
        try await service.setSession(accessToken: token)
        
        // Si no dio error, el usuario ya está autenticado
        self.isAuthenticated = true
    }
}
