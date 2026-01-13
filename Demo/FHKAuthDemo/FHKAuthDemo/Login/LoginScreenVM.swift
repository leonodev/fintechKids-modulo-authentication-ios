//
//  LoginScreenVM.swift
//  FHKAuthDemo
//
//  Created by Fredy Leon on 11/12/25.
//

import SwiftUI
import Combine
import Supabase
import FHKAuth
import FHKUtils

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
            try await loginActor.loginUser(platform: .supabase, email: self.email, password: self.password)
            isAuthenticated = true
        } catch let error as AuthDomainError {
            // Capturamos nuestros errores de dominio ya procesados
            self.errorMessage = error.userMessage
            isAuthenticated = false
        } catch {
            // Cualquier otro error que no hayamos previsto
            self.errorMessage = "\(error.localizedDescription)"
            isAuthenticated = false
        }
        

        isLoading = false
    }
}

extension AuthDomainError {
    
    public var userMessage: String {
        switch self {
            
        case .invalidCredentials:
            return "user y/o password wrong."
            
        case .userNotFound:
            return "user not found."
            
        case .emailNotConfirmed:
            return "email not confirmed."
            
        case .otpExpired:
            return "opt expired."
            
        case .tooManyRequests:
            return "too many requests. try again later."
          
        case .authenticationNotImplemented:
            return "authentication not implemented."
            
        case .refreshSession:
            return "refresh session. try again."
            
        case .unknown(let code):
            return "error unknown (\(code))."
        }
    }
}
