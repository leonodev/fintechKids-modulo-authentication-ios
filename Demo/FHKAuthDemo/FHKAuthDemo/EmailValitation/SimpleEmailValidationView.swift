//
//  SimpleEmailValidationView.swift
//  FHKAuthDemo
//
//  Created by Fredy Leon on 21/11/25.
//

import SwiftUI
import FHKAuth

struct SimpleEmailValidationView: View {
    @State private var email: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Valida tu Email")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 4) {
                TextField("usuario@ejemplo.com", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .keyboardType(.emailAddress)
                
                if !email.isEmpty {
                    let result = email.emailValidation
                    Text(result.message)
                        .font(.caption)
                        .foregroundColor(result.isValid ? .green : .red)
                        .padding(.horizontal, 8)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top, 40)
    }
}
