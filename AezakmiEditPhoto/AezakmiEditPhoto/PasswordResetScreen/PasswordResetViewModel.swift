//
//  PasswordResetViewModel.swift
//  AezakmiEditPhoto
//
//  Created by Александр Воробей on 22.04.2025.
//


import Foundation

@MainActor
class PasswordResetViewModel: ObservableObject {
    @Published var email = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSuccess = false
    
    private let auth: AuthService
    
    init(auth: AuthService) {
        self.auth = auth
    }
    
    func resetPassword() async {
        guard email.isValidEmail else {
            errorMessage = "Введите корректный email"
            return
        }
        
        isLoading = true
        errorMessage = nil
        isSuccess = false
        
        do {
            try await auth.sendPasswordReset(email: email)
            isSuccess = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
