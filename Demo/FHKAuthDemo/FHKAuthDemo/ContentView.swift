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
                NavigationLink("Ir a Vista Email Validation") {
                    SimpleEmailValidationView()
                }
                
                NavigationLink("Ir a KeyChain Validation") {
                    LoginView()
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
