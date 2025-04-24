//
//  AezakmiEditPhotoApp.swift
//  AezakmiEditPhoto
//
//  Created by Александр Воробей on 22.04.2025.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}

@main
struct AezakmiEditPhotoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            switch appState.flow {
            case .login:
                LoginView(viewModel: LoginViewModel(auth: appState.authService))
                    .environmentObject(appState)
            case .registration:
                RegisterView(viewModel: RegisterViewModel(auth: appState.authService))
                    .environmentObject(appState)
            case .verification:
                EmailVerificationView(viewModel: EmailVerificationViewModel(auth: appState.authService))
                    .environmentObject(appState)
            case .main:
                MainView(viewModel: MainViewModel())
                    .environmentObject(appState)
            }
        }
    }
}
