//
//  LoginView.swift
//  event_planning_app
//
//  Created by Artem on 17.04.25.
//
import SwiftUI
import SocialPlanningKit

struct LoginView: View {
    @Binding var userIsLoggedIn: Bool
    var switchToSignUp: () -> Void

    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome Back")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding(.top, 50)

            CustomTextField(icon: "envelope", placeholder: "Email", text: $email)
            SecureTextField(icon: "lock", placeholder: "Password", text: $password, showPassword: $showPassword)

            if !authViewModel.errorMessage.isEmpty {
                Text(authViewModel.errorMessage)
                    .foregroundColor(.red)
            }

            Button(action: {
                UIApplication.shared.endEditing()
                authViewModel.signIn(email: email, password: password) { success in
                    if success {
                        userIsLoggedIn = true
                        LocationManager.shared.startLocationUpdates()
                    }
                }
            }) {
                Text("Sign In")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.top)

            Button(action: switchToSignUp) {
                Text("Don't have an account? Sign Up")
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.top, 10)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

