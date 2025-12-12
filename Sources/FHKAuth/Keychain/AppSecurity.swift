//
//  AppSecurity.swift
//  FHKAuth
//
//  Created by Fredy Leon on 20/11/25.
//

import SwiftUI
import Foundation
import FHKConfig

// MARK: - Security Protocols
public protocol AppSecurityProtocol: Sendable {
    var authToken: String { get async }
    var refreshToken: String { get async }
    var user: KCUser? { get async }
    var settings: KCSettings? { get async }
    var isLoggedIn: Bool { get async }
    
    func setAuthToken(_ token: String) async
    func setRefreshToken(_ token: String) async
    func setUser(_ user: KCUser?) async
    func setSettings(_ settings: KCSettings?) async
    func login(user: KCUser, authToken: String, refreshToken: String) async
    func logout() async
    func updateSettings(theme: String?, notifications: Bool?) async
    func clearAllData() async throws
}

public actor AppSecurity: AppSecurityProtocol {
    public static let shared = AppSecurity()
    
    // Property wrappers - se acceden directamente
    @KeychainString(.authToken) private var storedAuthToken
    @KeychainString(.refreshToken) private var storedRefreshToken
    @KeychainStored<Configuration.LanguageType>(.appLanguage) private var storedLanguage
    @KeychainStored<KCUser>(.userCredentials) private var storedUser
    @KeychainStored<KCSettings>(.appSettings) private var storedSettings
    
    private init() {}
    
    // MARK: - Estado de solo lectura
    public var authToken: String {
        storedAuthToken  // Acceso directo, no .wrappedValue
    }
    
    public var refreshToken: String {
        storedRefreshToken  // Acceso directo
    }
    
    public var language: Configuration.LanguageType? {
        storedLanguage
    }
    
    // Método para guardar el idioma
    public func setLanguage(_ language: Configuration.LanguageType?) async {
        storedLanguage = language
    }
    
    public var user: KCUser? {
        storedUser  // Acceso directo
    }
    
    public var settings: KCSettings? {
        storedSettings  // Acceso directo
    }
    
    public var isLoggedIn: Bool {
        !authToken.isEmpty
    }
    
    // MARK: - Métodos para modificar estado
    public func setAuthToken(_ token: String) {
        storedAuthToken = token  // Asignación directa
    }
    
    public func setRefreshToken(_ token: String) {
        storedRefreshToken = token  // Asignación directa
    }
    
    public func setUser(_ user: KCUser?) {
        storedUser = user  // Asignación directa
    }
    
    public func setSettings(_ settings: KCSettings?) {
        storedSettings = settings  // Asignación directa
    }
    
    public func login(user: KCUser, authToken: String, refreshToken: String) {
        setUser(user)
        setAuthToken(authToken)
        setRefreshToken(refreshToken)
    }
    
    public func logout() {
        setUser(nil)
        setAuthToken("")
        setRefreshToken("")
    }
    
    public func updateSettings(theme: String? = nil, notifications: Bool? = nil) {
        let current = settings ?? KCSettings()
        let newSettings = KCSettings(
            theme: theme ?? current.theme,
            notifications: notifications ?? current.notifications
        )
        setSettings(newSettings)
    }
    
    public func clearAllData() async throws {
        // Limpiar todas las propiedades en memoria
        await logout()
        
        // Limpiar el Keychain
        try SecureKeychain.shared.clearAll()
    }
}
