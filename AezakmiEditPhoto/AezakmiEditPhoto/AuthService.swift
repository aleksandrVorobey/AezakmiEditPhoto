//
//  AuthService.swift
//  AezakmiEditPhoto
//
//  Created by Александр Воробей on 22.04.2025.
//


import FirebaseCore
import FirebaseAuth
import GoogleSignIn

protocol AuthService {
    func login(email: String, password: String) async throws -> User
    func register(email: String, password: String) async throws -> User
    func sendEmailVerification(for user: User) async throws
    func reloadUser(_ user: User) async throws -> Bool
    func signOut() throws
    func getCurrentUser() -> User?
    func sendPasswordReset(email: String) async throws
    func signInWithGoogle(presenting: UIViewController) async throws -> User
}


final class FirebaseAuthService: AuthService {
    func login(email: String, password: String) async throws -> User {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return result.user
    }
    
    func register(email: String, password: String) async throws -> User {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return result.user
    }
    
    func sendEmailVerification(for user: User) async throws {
        try await user.sendEmailVerification()
    }
    
    func reloadUser(_ user: User) async throws -> Bool {
        try await user.reload()
        return user.isEmailVerified
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func getCurrentUser() -> User? {
        return Auth.auth().currentUser
    }
    
    func sendPasswordReset(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    @MainActor
    func signInWithGoogle(presenting: UIViewController) async throws -> User {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing client ID"])
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenting)
        let idToken = result.user.idToken?.tokenString
        let accessToken = result.user.accessToken.tokenString
        
        guard let idToken = idToken else {
            throw NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No ID Token"])
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        let authResult = try await Auth.auth().signIn(with: credential)
        return authResult.user
    }
}
