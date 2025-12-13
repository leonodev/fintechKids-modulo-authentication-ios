//
//  LoginViewModel.swift
//  FHKAuthDemo
//
//  Created by Fredy Leon on 21/11/25.
//

import SwiftUI
import Combine
import FHKAuth
import FHKStorage
import FHKUtils

@MainActor
final class LoginViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: KCUser?
    @Published var appSettings: KCSettings?
    
    // MARK: - Dependencies
    private let storage: UserDefaultsProtocol
    
    // MARK: - Initialization
    init(storage: UserDefaultsProtocol = UserDefaultStorage()) {
        self.storage = storage
    }
    
    // MARK: - Authentication Operations
    func login() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Por favor ingresa email y contraseña"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Simular llamada a API
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            let user = KCUser(
                id: UUID().uuidString,
                email: email,
                lastLogin: Date()
            )
            
            let authToken = generateAuthToken()
            let refreshToken = generateRefreshToken()
            
            do {
                try await storage.save(authToken, forKey: UserDefaultsKeys.authToken)
                Logger.info("authToken saved success")
                
                try await storage.save(refreshToken, forKey: UserDefaultsKeys.authToken)
                Logger.info("refreshToken saved success")
                
            } catch {
                Logger.error("Error saving: \(error)")
            }
            
            do {
                try await storage.save(user, forKey: UserDefaultsKeys.authToken)
                Logger.info("user saved success")
            } catch {
                Logger.error("Error saving: \(error)")
            }
            
        } catch {
            errorMessage = "Error en el login: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func readAuthToken() async -> String {
        do {
            let languageCode = try await storage.read(String.self,
                                                      forKey: UserDefaultsKeys.authToken)
            return languageCode ?? "-"
        } catch {
            Logger.error("Error saving: \(error)")
            return "-"
        }
    }
    
    // MARK: - Helper Methods
    private func generateAuthToken() -> String {
        return "auth_token_\(UUID().uuidString)_\(Date().timeIntervalSince1970)"
    }
    
    private func generateRefreshToken() -> String {
        return "refresh_token_\(UUID().uuidString)_\(Date().timeIntervalSince1970)"
    }
}

public extension UserDefaultsKeys {
    static let authToken = "authorization_token"
    static let refreshToken = "refresh_token"
    static let user = "user"
}
