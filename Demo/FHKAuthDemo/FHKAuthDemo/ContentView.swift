//
//  ContentView.swift
//  FHKAuthDemo
//
//  Created by Fredy Leon on 15/11/25.
//

import SwiftUI
import FHKAuth

struct ContentView: View {
    var body: some View {
        MenuNavigationOptions()
    }
}

struct MenuNavigationOptions: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Email Validation") {
                    SimpleEmailValidationView()
                }
                
                NavigationLink("KeyChain Validation") {
                    LoginView()
                }
                
                NavigationLink("Login Supabase") {
                    LoginScreen()
                }
                
                NavigationLink("Register Supabase") {
                    RegisterScreen()
                }
            }
            .navigationTitle("FHK Auth Demo")
        }
        .padding()
    }
}

#Preview {
    MenuNavigationOptions()
}

