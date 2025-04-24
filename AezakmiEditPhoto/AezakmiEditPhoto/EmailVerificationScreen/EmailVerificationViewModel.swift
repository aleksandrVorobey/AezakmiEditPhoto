//
//  EmailVerificationViewModel.swift
//  AezakmiEditPhoto
//
//  Created by Александр Воробей on 22.04.2025.
//


import Foundation
import FirebaseAuth

@MainActor
class EmailVerificationViewModel: ObservableObject {
    @Published var isChecking = false
    @Published var isResending = false
    @Published var errorMessage: String?
    @Published var resentSuccess = false
    @Published var emailVerified = false

    private let auth: AuthService

    init(auth: AuthService) {
        self.auth = auth
    }

    func checkEmailVerification() async {
        guard let user = auth.getCurrentUser() else {
            errorMessage = "Пользователь не найден"
            return
        }

        isChecking = true
        errorMessage = nil

        do {
            let verified = try await auth.reloadUser(user)
            emailVerified = verified
        } catch {
            errorMessage = error.localizedDescription
        }

        isChecking = false
    }

    func resendVerificationEmail() async {
        guard let user = auth.getCurrentUser() else {
            errorMessage = "Пользователь не найден"
            return
        }

        isResending = true
        errorMessage = nil

        do {
            try await auth.sendEmailVerification(for: user)
            resentSuccess = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isResending = false
    }
}
