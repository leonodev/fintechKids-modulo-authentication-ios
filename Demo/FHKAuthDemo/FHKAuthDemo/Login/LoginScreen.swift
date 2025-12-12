//
//  LoginScreen.swift
//  FHKAuthDemo
//
//  Created by Fredy Leon on 11/12/25.
//

import SwiftUI
import FHKAuth
import Supabase

struct LoginScreen: View {
    @StateObject var viewModel: LoginScreenVM = LoginScreenVM()
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Start Sesión Bank")
                .font(.largeTitle).bold()
            
            TextField("Email", text: $viewModel.email)
                .keyboardType(.emailAddress)
                .textFieldStyle(.roundedBorder)
            
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)
            
            Button {
                Task {
                    await viewModel.performLogin()
                }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Access")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading || viewModel.email.isEmpty || viewModel.password.isEmpty)
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
        
            if viewModel.isAuthenticated {
                Text("¡Autentication Success! ✅")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .onAppear {
            viewModel.email = "usertest@fhk.es"
            viewModel.password = "1234567890"
        }
    }
}

#Preview {
    LoginScreen(viewModel: LoginScreenVM())
}
