//
//  LoginScreenVM.swift
//  FHKAuthDemo
//
//  Created by Fredy Leon on 11/12/25.
//

import SwiftUI
import Combine
import FHKAuth
import Supabase

final class LoginScreenVM: ObservableObject {
    private let loginActor: Login
    
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Estado de la sesión
    @Published var isAuthenticated = false
   
    init(loginActor: Login = Login(factory: DefaultAuthServiceFactory())) {
        self.loginActor = loginActor
    }
    
    @MainActor
    func performLogin() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await loginActor.loginUser(platform: .supabase,
                                           email: self.email,
                                           password: self.password)
            
            isAuthenticated = true
        } catch {
            // Manejo de errores
            errorMessage = "Login failed: \(error.localizedDescription)"
            isAuthenticated = false
        }
        

        isLoading = false
    }
}
