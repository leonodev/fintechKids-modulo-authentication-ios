//
//  AuthProtocol.swift
//  FHKAuth
//
//  Created by Fredy Leon on 10/12/25.
//

import Foundation
import Supabase
import FHKUtils
import FHKCore

public protocol AuthServiceFactory: Sendable {
    func makeAuthService(for platform: Login.AuthPlatform) throws -> any AuthProtocol
}

public final class DefaultAuthServiceFactory: AuthServiceFactory {
    public init(){}
    public func makeAuthService(for platform: Login.AuthPlatform) throws -> any AuthProtocol {
        
        switch platform {
        case .supabase:
            return SupabaseAuth()
            
        case .firebase:
            throw FHKDomainError.authenticationNotImplemented
        }
    }
}


public actor Login {
    
    public enum AuthPlatform {
        case supabase
        case firebase
    }
    
    private let factory: any AuthServiceFactory
    public var isAuthenticated: Bool = false
    
    public init(factory: any AuthServiceFactory) {
        self.factory = factory
    }
    
    public func loginUser(platform: AuthPlatform, email: String, password: String) async throws -> String {
        let service = try factory.makeAuthService(for: platform)
        
        let response = try await service.loginUser(email: email, password: password)
        self.isAuthenticated = response.accessToken != nil
        
        guard let token = response.accessToken else {
            throw FHKDomainError.accessToken
        }
        
        return token
    }
    
    public func registerUser(platform: AuthPlatform, email: String, password: String) async throws {
        let service = try factory.makeAuthService(for: platform)
       
        let response = try await service.registerUser(email: email, password: password)
        self.isAuthenticated = ((response.user.identities?.isEmpty) != nil)
    }
    
    public func restoreSession(platform: AuthPlatform, token: String) async throws {
        let service = try factory.makeAuthService(for: platform)
        
        // Llamamos al nuevo método que acabamos de crear
        try await service.setSession(accessToken: token)
        
        // Si no dio error, el usuario ya está autenticado
        self.isAuthenticated = true
    }
}
