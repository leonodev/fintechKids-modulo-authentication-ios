//
//  RegisterScreen.swift
//  FHKAuthDemo
//
//  Created by Fredy Leon on 30/1/26.
//

import SwiftUI
import FHKAuth
import Supabase

struct RegisterScreen: View {
    @StateObject var viewModel: RegisterScreenVM = RegisterScreenVM()
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Register")
                .font(.largeTitle).bold()
            
            TextField("Email", text: $viewModel.email)
                .keyboardType(.emailAddress)
                .textFieldStyle(.roundedBorder)
            
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)
            
            Button {
                Task {
                    await viewModel.performRegister()
                }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Register Now")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading || viewModel.email.isEmpty || viewModel.password.isEmpty)
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
        
            if viewModel.isRegistered {
                Text("¡Registered Success! ✅")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .onAppear {
            viewModel.email = "leonfrcol@gmail.com"
            viewModel.password = "1234567890"
        }
    }
}

#Preview {
    LoginScreen(viewModel: LoginScreenVM())
}
