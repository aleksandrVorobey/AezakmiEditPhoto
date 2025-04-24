//
//  LoginViewModel.swift
//  AezakmiEditPhoto
//
//  Created by Александр Воробей on 22.04.2025.
//


import Foundation
import FirebaseAuth

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isLoggedIn = false
    @Published var isEmailVerified = false
    
    private let auth: AuthService
    
    init(auth: AuthService = FirebaseAuthService()) {
        self.auth = auth
    }
    
    func login() async {
        guard email.isValidEmail else {
            errorMessage = "Введите корректный email"
            return
        }
        
        guard password.isValidPassword else {
            errorMessage = "Пароль должен содержать минимум 6 символов"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await auth.login(email: email, password: password)
            let verified = try await auth.reloadUser(user)
            isEmailVerified = verified
            isLoggedIn = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
