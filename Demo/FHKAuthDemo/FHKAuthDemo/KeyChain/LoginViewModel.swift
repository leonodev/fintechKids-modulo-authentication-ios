//
//  LoginViewModel.swift
//  FHKAuthDemo
//
//  Created by Fredy Leon on 21/11/25.
//

import SwiftUI
import Combine
import FHKDomain

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
    
    // MARK: - Initialization
    init() {}
    
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
        } catch {
            errorMessage = "Error en el login: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
