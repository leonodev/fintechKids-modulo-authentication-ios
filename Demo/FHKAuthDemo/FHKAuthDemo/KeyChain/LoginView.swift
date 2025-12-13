//
//  LoginView.swift
//  FHKAuthDemo
//
//  Created by Fredy Leon on 21/11/25.
//

import SwiftUI
import FHKAuth
import FHKStorage

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel = LoginViewModel()
    @State private var showingSecurityInfo = false
    @State private var newTheme = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerView
                    
                    if viewModel.isLoading {
                        loadingView
                    }
                    
                    if viewModel.isLoggedIn {
                        loggedInView
                    } else {
                        loginFormView
                    }
                    
                    operationsView
                    
                    if let error = viewModel.errorMessage {
                        errorView(error)
                    }
                }
                .padding()
            }
            .navigationTitle("Secure App")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSecurityInfo = true }) {
                        Image(systemName: "info.circle")
                    }
                }
            }
            .sheet(isPresented: $showingSecurityInfo) {
                securityInfoSheet
            }
            .onAppear {
                Task {
                    await viewModel.readAuthToken()
                }
            }
        }
    }
}

// MARK: - Subviews
private extension LoginView {
    var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "lock.shield")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Secure Keychain Demo")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Gestión segura de credenciales")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical)
    }
    
    var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Procesando...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
    
    var loginFormView: some View {
        VStack(spacing: 20) {
            Text("Iniciar Sesión")
                .font(.title3)
                .fontWeight(.medium)
            
            VStack(spacing: 16) {
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                SecureField("Contraseña", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.password)
            }
            
            Button(action: { Task { await viewModel.login() } }) {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Iniciar Sesión")
                        .fontWeight(.semibold)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading || viewModel.email.isEmpty || viewModel.password.isEmpty)
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
    
    var loggedInView: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bienvenido")
                        .font(.headline)
                    
                    Text(viewModel.currentUser?.email ?? "Usuario")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let settings = viewModel.appSettings {
                        Text("Tema: \(settings.theme) • Notificaciones: \(settings.notifications ? "ON" : "OFF")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button("Cerrar Sesión") {
                    //Task { await viewModel.logout() }
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(16)
    }
    
    var operationsView: some View {
        VStack(spacing: 20) {
            Text("Operaciones de Keychain")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Operaciones de Settings
            settingsOperationsView
        }
    }
    
    var settingsOperationsView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Configuración")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let settings = viewModel.appSettings {
                    Text("Actual: \(settings.theme)")
                        .font(.caption)
                        .padding(4)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            
            if let settings = viewModel.appSettings {
                Toggle("Notificaciones: \(settings.notifications ? "Activadas" : "Desactivadas")",
                      isOn: Binding(
                        get: { settings.notifications },
                        set: { newValue in
                           
                        }
                      ))
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
    
    func errorView(_ error: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.red)
                .font(.title3)
            
            Text(error)
                .foregroundColor(.red)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            Button(action: { viewModel.errorMessage = nil }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
    }
    
    var securityInfoSheet: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Secure Keychain Demo")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Esta demo muestra una implementación segura del Keychain de iOS usando Swift 6")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Características:")
                            .font(.headline)
                        
                        FeatureRow(icon: "lock.shield", text: "Almacenamiento seguro en Keychain")
                        FeatureRow(icon: "person.crop.circle", text: "Gestión de usuarios y tokens")
                        FeatureRow(icon: "gearshape", text: "Configuración persistente")
                        FeatureRow(icon: "checkmark.shield", text: "Validación de sesiones")
                        FeatureRow(icon: "trash", text: "Limpieza segura de datos")
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Cómo probar:")
                            .font(.headline)
                        
                        InstructionRow(number: "1", text: "Inicia sesión con cualquier email y contraseña")
                        InstructionRow(number: "2", text: "Explora las operaciones de configuración")
                        InstructionRow(number: "3", text: "Prueba las funciones de seguridad")
                        InstructionRow(number: "4", text: "Los datos persisten entre reinicios de la app")
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Información de Seguridad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        showingSecurityInfo = false
                    }
                }
            }
        }
    }
}

// MARK: - Helper Views
private struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
        }
    }
}

private struct InstructionRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(Circle().fill(Color.blue))
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
        }
    }
}

// MARK: - Previews
#Preview("Login State") {
    LoginView()
        .environmentObject(LoginViewModel())
}

#Preview("Logged In State") {
    let viewModel = LoginViewModel()
    
    LoginView()
        .environmentObject(viewModel)
        .onAppear {
            Task {
                await MainActor.run {
                    viewModel.isLoggedIn = true
                    viewModel.currentUser = KCUser(
                        id: "preview-123",
                        email: "usuario@ejemplo.com",
                        lastLogin: Date()
                    )
                    viewModel.appSettings = KCSettings(theme: "dark", notifications: true)
                }
            }
        }
}

#Preview("Loading State") {
    let viewModel = LoginViewModel()
    
    LoginView()
        .environmentObject(viewModel)
        .onAppear {
            Task {
                await MainActor.run {
                    viewModel.isLoading = true
                    viewModel.email = "test@example.com"
                }
            }
        }
}

#Preview("Error State") {
    let viewModel = LoginViewModel()
    
    LoginView()
        .environmentObject(viewModel)
        .onAppear {
            Task {
                await MainActor.run {
                    viewModel.errorMessage = "Error de conexión. Por favor verifica tu conexión a internet e intenta nuevamente."
                }
            }
        }
}
