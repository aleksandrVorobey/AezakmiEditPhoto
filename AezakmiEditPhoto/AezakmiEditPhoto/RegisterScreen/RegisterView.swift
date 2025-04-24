//
//  RegisterView.swift
//  AezakmiEditPhoto
//
//  Created by Александр Воробей on 22.04.2025.
//


import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel: RegisterViewModel
    @EnvironmentObject var appState: AppState
    @State private var showError = false
    @State private var errorWrapper: ErrorWrapper?
    
    init(viewModel: RegisterViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("Регистрация")
                .font(.largeTitle.bold())
            
            TextField("Email", text: $viewModel.email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .primaryTextFieldStyle()
            
            SecureField("Пароль", text: $viewModel.password)
                .primaryTextFieldStyle()
            
            SecureField("Подтвердите пароль", text: $viewModel.confirmPassword)
                .primaryTextFieldStyle()
            
            if viewModel.isLoading {
                ProgressView()
            }
            
            Button("Зарегистрироваться") {
                Task {
                    await viewModel.register()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)
            
            Spacer()
        }
        .padding()
        .onReceive(viewModel.$registrationSuccess) { success in
            if success {
                appState.flow = .verification
            }
        }
        .onReceive(viewModel.$errorMessage) { message in
            if let message = message {
                errorWrapper = ErrorWrapper(message: message)
                showError = true
            }
        }
        .alert("Ошибка", isPresented: $showError, presenting: errorWrapper) { _ in
            Button("ОК", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: { wrapper in
            Text(wrapper.message)
        }
    }
}

#Preview {
    RegisterView(viewModel: RegisterViewModel())
        .environmentObject(AppState())
}
