//
//  MockAppSecurity.swift
//  FHKAuth
//
//  Created by Fredy Leon on 21/11/25.
//

#if DEBUG
// MARK: - Mocks para Testing
public actor MockAppSecurity: AppSecurityProtocol {
    public var authToken: String = ""
    public var refreshToken: String = ""
    public var user: KCUser?
    public var settings: KCSettings?
    
    public var isLoggedIn: Bool {
        !authToken.isEmpty
    }
    
    // Track method calls for verification
    private(set) var methodCalls: [String] = []
    
    public init() {}
    
    public func setAuthToken(_ token: String) {
        methodCalls.append("setAuthToken(\(token))")
        authToken = token
    }
    
    public func setRefreshToken(_ token: String) {
        methodCalls.append("setRefreshToken(\(token))")
        refreshToken = token
    }
    
    public func setUser(_ user: KCUser?) {
        methodCalls.append("setUser(\(user?.email ?? "nil"))")
        self.user = user
    }
    
    public func setSettings(_ settings: KCSettings?) {
        methodCalls.append("setSettings(\(settings?.theme ?? "nil"))")
        self.settings = settings
    }
    
    public func login(user: KCUser, authToken: String, refreshToken: String) {
        methodCalls.append("login(user: \(user.email), authToken: \(authToken))")
        self.user = user
        self.authToken = authToken
        self.refreshToken = refreshToken
    }
    
    public func logout() {
        methodCalls.append("logout")
        user = nil
        authToken = ""
        refreshToken = ""
        settings = nil
    }
    
    public func updateSettings(theme: String?, notifications: Bool?) {
        methodCalls.append("updateSettings(theme: \(theme ?? "nil"), notifications: \(notifications ?? false))")
        let current = settings ?? KCSettings()
        settings = KCSettings(
            theme: theme ?? current.theme,
            notifications: notifications ?? current.notifications
        )
    }
    
    public func clearAllData() async throws {
        methodCalls.append("clearAllData")
        await logout()
    }
    
    public func reset() {
        methodCalls.removeAll()
        logout()
    }
}

#endif
