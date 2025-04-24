//
//  EmailVerificationView.swift
//  AezakmiEditPhoto
//
//  Created by Александр Воробей on 22.04.2025.
//


import SwiftUI

struct EmailVerificationView: View {
    @StateObject private var viewModel: EmailVerificationViewModel
    @EnvironmentObject var appState: AppState
    @State private var showError = false
    @State private var showSuccess = false

    init(viewModel: EmailVerificationViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Письмо с подтверждением отправлено")
                .font(.title)
                .multilineTextAlignment(.center)

            Text("Пожалуйста, перейдите по ссылке в письме, чтобы завершить регистрацию.")
                .font(.body)
                .multilineTextAlignment(.center)

            if viewModel.isChecking {
                ProgressView()
            }

            Button("Я подтвердил") {
                Task {
                    await viewModel.checkEmailVerification()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isChecking)

            if viewModel.isResending {
                ProgressView()
            } else {
                Button("Отправить письмо повторно") {
                    Task {
                        await viewModel.resendVerificationEmail()
                    }
                }
                .font(.footnote)
            }

            Button("Выйти") {
                try? appState.authService.signOut()
                appState.flow = .login
            }
            .font(.footnote)
            .padding(.top)

            Spacer()
        }
        .padding()
        .onReceive(viewModel.$emailVerified) { verified in
            if verified {
                appState.flow = .main
            }
        }
        .onReceive(viewModel.$resentSuccess) { success in
            if success {
                showSuccess = true
            }
        }
        .onReceive(viewModel.$errorMessage) { message in
            showError = message != nil
        }
        .alert("Ошибка", isPresented: $showError) {
            Button("ОК", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .alert("Письмо отправлено повторно", isPresented: $showSuccess) {
            Button("ОК", role: .cancel) { }
        }
    }
}
