//
//  LoginView.swift
//  AezakmiEditPhoto
//
//  Created by Александр Воробей on 22.04.2025.
//


import SwiftUI
import GoogleSignInSwift

struct ErrorWrapper: Identifiable {
    let id = UUID()
    let message: String
}

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    @EnvironmentObject var appState: AppState
    @State private var showError = false
    @State private var errorWrapper: ErrorWrapper?
    @State private var showResetSheet = false
    
    init(viewModel: LoginViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()
                Text("Вход")
                    .font(.largeTitle.bold())
                
                TextField("Email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .primaryTextFieldStyle()
                
                SecureField("Пароль", text: $viewModel.password)
                    .primaryTextFieldStyle()
                
                if viewModel.isLoading {
                    ProgressView()
                }
                
                Button("Войти") {
                    Task {
                        await viewModel.login()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading)
                
                GoogleSignInButton {
                    Task {
                        if let rootVC = UIApplication.shared.rootViewController {
                            do {
                                let user = try await appState.authService.signInWithGoogle(presenting: rootVC)
                                if user.isEmailVerified {
                                    appState.flow = .main
                                } else {
                                    appState.flow = .verification
                                }
                            } catch {
                                errorWrapper = ErrorWrapper(message: error.localizedDescription)
                                showError = true
                            }
                        }
                    }
                }
                .frame(height: 50)
                .padding(.top)
                .padding(.horizontal, 14)
                
                Button("Забыли пароль?") {
                    showResetSheet = true
                }
                .font(.footnote)
                
                NavigationLink("Создать аккаунт") {
                    RegisterView(viewModel: RegisterViewModel(auth: appState.authService))
                }
                
                .padding(.top, 8)
                .font(.footnote)
                
                Spacer()
            }
            .padding()
            .onReceive(viewModel.$isLoggedIn) { loggedIn in
                if loggedIn {
                    if viewModel.isEmailVerified {
                        appState.flow = .main
                    } else {
                        appState.flow = .verification
                    }
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
            .sheet(isPresented: $showResetSheet) {
                PasswordResetView(viewModel: PasswordResetViewModel(auth: appState.authService))
            }
        }
    }
}


#Preview {
    LoginView(viewModel: LoginViewModel())
        .environmentObject(AppState())
}
