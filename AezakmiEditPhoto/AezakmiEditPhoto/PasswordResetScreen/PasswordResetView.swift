//
//  PasswordResetView.swift
//  AezakmiEditPhoto
//
//  Created by Александр Воробей on 22.04.2025.
//


import SwiftUI

struct PasswordResetView: View {
    @StateObject private var viewModel: PasswordResetViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showError = false
    @State private var showSuccess = false
    
    init(viewModel: PasswordResetViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("Восстановление пароля")
                .font(.title2.bold())
            
            TextField("Email", text: $viewModel.email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .primaryTextFieldStyle()
            
            if viewModel.isLoading {
                ProgressView()
            }
            
            Button("Восстановить") {
                Task {
                    await viewModel.resetPassword()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)
            
            Spacer()
        }
        .padding()
        .onReceive(viewModel.$errorMessage) { message in
            showError = message != nil
        }
        .onReceive(viewModel.$isSuccess) { success in
            if success {
                showSuccess = true
            }
        }
        .alert("Ошибка", isPresented: $showError) {
            Button("ОК", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Произошла ошибка")
        }
        .alert("Письмо отправлено", isPresented: $showSuccess) {
            Button("ОК") {
                dismiss()
            }
        } message: {
            Text("Мы отправили вам письмо для сброса пароля.")
        }
    }
}

#Preview {
    PasswordResetView(viewModel: PasswordResetViewModel(auth: AppState().authService))
}
