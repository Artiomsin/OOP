//
//  SignUpView.swift
//  event_planning_app
//
//  Created by Artem on 17.04.25.
//

import SwiftUI
import SocialPlanningKit // или название модуля, где лежит LocationManager

struct SignUpView: View {
    @Binding var userIsLoggedIn: Bool
    var switchToSignIn: () -> Void

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding(.top, 50)

            CustomTextField(icon: "person", placeholder: "Name", text: $name)
            CustomTextField(icon: "envelope", placeholder: "Email", text: $email)
            SecureTextField(icon: "lock", placeholder: "Password", text: $password, showPassword: $showPassword)
            SecureTextField(icon: "lock", placeholder: "Confirm Password", text: $confirmPassword, showPassword: $showConfirmPassword)

            if !authViewModel.errorMessage.isEmpty {
                Text(authViewModel.errorMessage)
                    .foregroundColor(.red)
            }

            Button(action: {
                UIApplication.shared.endEditing()
                authViewModel.signUp(name: name, email: email, password: password, confirmPassword: confirmPassword) { success in
                    if success {
                        userIsLoggedIn = true
                        LocationManager.shared.startLocationUpdates()
                    }
                }
            }) {
                Text("Sign Up")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.green)
                    .cornerRadius(12)
            }
            .padding(.top)

            Button(action: switchToSignIn) {
                Text("Already have an account? Sign In")
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.top, 10)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }
}
