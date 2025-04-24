//
//  AppState.swift
//  AezakmiEditPhoto
//
//  Created by Александр Воробей on 22.04.2025.
//


import Foundation
import FirebaseAuth

enum AppFlow {
    case login
    case registration
    case verification
    case main
}

class AppState: ObservableObject {
    @Published var flow: AppFlow
    let authService: AuthService
    
    init(authService: AuthService = FirebaseAuthService()) {
        self.authService = authService
        
        if let user = authService.getCurrentUser() {
            self.flow = user.isEmailVerified ? .main : .verification
        } else {
            self.flow = .login
        }
    }
    
    
    func signOut() {
        do {
            try authService.signOut()
            flow = .login
        } catch {
            print("Ошибка выхода: \(error.localizedDescription)")
        }
    }
}

