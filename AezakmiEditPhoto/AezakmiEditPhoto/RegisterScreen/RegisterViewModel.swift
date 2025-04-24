//
//  RegisterViewModel.swift
//  AezakmiEditPhoto
//
//  Created by Александр Воробей on 22.04.2025.
//


import Foundation
import FirebaseAuth

@MainActor
class RegisterViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var registrationSuccess = false
    
    private let auth: AuthService
    
    init(auth: AuthService = FirebaseAuthService()) {
        self.auth = auth
    }
    
    func register() async {
        guard email.isValidEmail else {
            errorMessage = "Неверный формат email"
            return
        }
        
        guard password.isValidPassword else {
            errorMessage = "Пароль должен содержать минимум 6 символов"
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Пароли не совпадают"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await auth.register(email: email, password: password)
            try await auth.sendEmailVerification(for: user)
            registrationSuccess = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
