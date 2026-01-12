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

public protocol AuthProtocol: Sendable {
    func loginUser(email: String, password: String) async throws -> AuthResponseProtocol
    func logoutUser() async throws
    func refreshSession() async throws -> AuthResponseProtocol

    // MARK: - User Data
    var isUserAuthenticated: Bool { get }
}

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
            throw AuthDomainError.authenticationNotImplemented
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
    
    public func loginUser(platform: AuthPlatform, email: String, password: String) async throws {
        let service = try factory.makeAuthService(for: platform)
       
        let response = try await service.loginUser(email: email, password: password)
        self.isAuthenticated = response.accessToken != nil
    }
}
