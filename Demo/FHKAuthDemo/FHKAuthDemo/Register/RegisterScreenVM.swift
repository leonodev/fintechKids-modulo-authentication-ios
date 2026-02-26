//
//  RegisterScreenVM.swift
//  FHKAuthDemo
//
//  Created by Fredy Leon on 30/1/26.
//

import SwiftUI
import Combine
import FHKAuth
import FHKDomain

final class RegisterScreenVM: ObservableObject {
    private let loginActor: Login
    
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Estado de la sesión
    @Published var isRegistered = false
   
    init(loginActor: Login = Login(factory: DefaultAuthServiceFactory(), country: .spanish)) {
        self.loginActor = loginActor
    }
    
    @MainActor
    func performRegister() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await loginActor.registerUser(platform: .supabase,
                                              email: self.email,
                                              password: self.password)
            isRegistered = true
        } catch let error as FHKDomainError {
            self.errorMessage = "\(error.localizedDescription)"
            isRegistered = false
        } catch {
            // Cualquier otro error que no hayamos previsto
            self.errorMessage = "\(error.localizedDescription)"
            isRegistered = false
        }
        

        isLoading = false
    }
}
