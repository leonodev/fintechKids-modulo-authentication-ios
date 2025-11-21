//
//  LoginViewModel.swift
//  FHKAuthDemo
//
//  Created by Fredy Leon on 21/11/25.
//

import SwiftUI
import Combine
import FHKAuth


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
    private let security: AppSecurityProtocol
    
    // MARK: - Initialization
    init(security: AppSecurityProtocol = AppSecurity.shared) {
        self.security = security
        loadInitialState()
    }
    
    // MARK: - Setup
    private func loadInitialState() {
        Task {
            await refreshState()
        }
    }
    
    private func refreshState() async {
        let loggedIn = await security.isLoggedIn
        let user = await security.user
        let settings = await security.settings
        
        await MainActor.run {
            self.isLoggedIn = loggedIn
            self.currentUser = user
            self.appSettings = settings
        }
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
            
            // Guardar en el security manager
            await security.login(
                user: user,
                authToken: authToken,
                refreshToken: refreshToken
            )
            
            // Actualizar estado local
            await refreshState()
            
            // Limpiar formulario
            await MainActor.run {
                email = ""
                password = ""
            }
            
        } catch {
            errorMessage = "Error en el login: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func logout() async {
        await security.logout()
        await refreshState()
        await MainActor.run {
            email = ""
            password = ""
            errorMessage = nil
        }
    }
    
    func refreshToken() async {
        let newToken = generateAuthToken()
        await security.setAuthToken(newToken)
        await refreshState()
        errorMessage = nil
    }
    
    // MARK: - User Operations
    func updateUserProfile() async {
        guard let currentUser = currentUser else { return }
        
        let updatedUser = KCUser(
            id: currentUser.id,
            email: currentUser.email,
            lastLogin: Date()
        )
        
        await security.setUser(updatedUser)
        await refreshState()
    }
    
    func getCurrentUserInfo() async -> (user: KCUser?, token: String) {
        let user = await security.user
        let token = await security.authToken
        return (user, token)
    }
    
    // MARK: - Settings Operations
    func loadAppSettings() async {
        let settings = await security.settings
        await MainActor.run {
            appSettings = settings
        }
    }
    
    func updateAppSettings(theme: String? = nil, notifications: Bool? = nil) async {
        await security.updateSettings(theme: theme, notifications: notifications)
        await refreshState()
    }
    
    func resetAppSettings() async {
        await security.setSettings(KCSettings())
        await refreshState()
    }
    
    // MARK: - Security Operations
    func checkIfTokenExists() async -> Bool {
        return await security.isLoggedIn
    }
    
    func validateCurrentSession() async -> Bool {
        let isValid = await security.isLoggedIn
        if !isValid {
            await logout()
        }
        return isValid
    }
    
    func clearAllSecurityData() async {
        do {
            try await security.clearAllData()
            await refreshState()
            errorMessage = "Todos los datos de seguridad han sido limpiados"
        } catch {
            errorMessage = "Error limpiando datos: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Helper Methods
    private func generateAuthToken() -> String {
        return "auth_token_\(UUID().uuidString)_\(Date().timeIntervalSince1970)"
    }
    
    private func generateRefreshToken() -> String {
        return "refresh_token_\(UUID().uuidString)_\(Date().timeIntervalSince1970)"
    }
    
    // MARK: - Debug/Info
    func getSecurityInfo() async -> String {
        let token = await security.authToken
        let user = await security.user
        let settings = await security.settings
        
        var info = "Estado de Seguridad:\n"
        info += "• Logged In: \(isLoggedIn)\n"
        info += "• Token: \(token.isEmpty ? "No" : "Sí")\n"
        info += "• User: \(user?.email ?? "None")\n"
        info += "• Settings: \(settings != nil ? "Cargados" : "No cargados")\n"
        
        return info
    }
}
