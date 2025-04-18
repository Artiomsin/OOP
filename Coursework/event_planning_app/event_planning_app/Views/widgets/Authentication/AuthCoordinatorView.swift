//
//  AuthCoordinatorView.swift
//  event_planning_app
//
//  Created by Artem on 17.04.25.
//

import SwiftUI

struct AuthCoordinatorView: View {
    @Binding var userIsLoggedIn: Bool
    @State private var isSignUp = false

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.black.opacity(0.8)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                if isSignUp {
                    SignUpView(
                        userIsLoggedIn: $userIsLoggedIn,
                        switchToSignIn: { withAnimation { isSignUp = false } }
                    )
                    .transition(.move(edge: .trailing))
                } else {
                    LoginView(
                        userIsLoggedIn: $userIsLoggedIn,
                        switchToSignUp: { withAnimation { isSignUp = true } }
                    )
                    .transition(.move(edge: .leading))
                }
            }
        }
    }
}
#Preview {
    AuthCoordinatorView(userIsLoggedIn: .constant(false))
}
