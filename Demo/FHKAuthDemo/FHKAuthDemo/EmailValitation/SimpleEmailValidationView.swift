//
//  SimpleEmailValidationView.swift
//  FHKAuthDemo
//
//  Created by Fredy Leon on 21/11/25.
//

import SwiftUI
import FHKAuth
import FHKUtils

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
                
//                if !email.isEmpty {
//                    let isValidEmail = email.isValidEmail
//                    Text(isValidEmail ? "Email valid" : "Email invalid")
//                        .font(.caption)
//                        .foregroundColor(isValidEmail ? .green : .red)
//                        .padding(.horizontal, 8)
//                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top, 40)
    }
}
