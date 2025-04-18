import SwiftUI

struct AuthView: View {
    @Binding var userIsLoggedIn: Bool
    @State private var isSignUp = false
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        ZStack {
            // Новый темный градиентный фон
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.black.opacity(0.75), Color.black.opacity(0.95)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Event Planning")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                
                VStack(spacing: 16) {
                    if isSignUp {
                        CustomTextField(icon: "person", placeholder: "Name", text: $name)
                    }
                    CustomTextField(icon: "envelope", placeholder: "Email", text: $email)
                    SecureTextField(icon: "lock", placeholder: "Password", text: $password, showPassword: $showPassword)
                    
                    if isSignUp {
                        SecureTextField(icon: "lock", placeholder: "Confirm Password", text: $confirmPassword, showPassword: $showConfirmPassword)
                    }
                }
                .padding(.horizontal, 20)
                
                // Ошибки аутентификации
                if !authViewModel.errorMessage.isEmpty {
                    Text(authViewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                }
                
                VStack(spacing: 12) {
                    Button(action: {
                        UIApplication.shared.endEditing() // Закрытие клавиатуры перед анимацией
                        withAnimation {
                            isSignUp ? signUp() : signIn()
                        }
                    }) {
                        Text(isSignUp ? "Sign Up" : "Sign In")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal, 20)
                    
                    Button(action: {
                        UIApplication.shared.endEditing() // Закрытие клавиатуры
                        withAnimation {
                            isSignUp.toggle()
                        }
                    }) {
                        Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .opacity(0.7)
                    }
                }
                .padding(.bottom, 40)
                Spacer()
            }
            .animation(.easeInOut(duration: 0.3), value: isSignUp)
        }
    }
    
    private func signUp() {
        authViewModel.signUp(name: name, email: email, password: password, confirmPassword: confirmPassword) { success in
            if success {
                userIsLoggedIn = true
                LocationManager.shared.startLocationUpdates()
            }
        }
    }
    
    private func signIn() {
        authViewModel.signIn(email: email, password: password) { success in
            if success {
                userIsLoggedIn = true
                LocationManager.shared.startLocationUpdates()
            }
        }
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    AuthView(userIsLoggedIn: .constant(false))
}


/*import SwiftUI
 
 struct AuthView: View {
     @Binding var userIsLoggedIn: Bool
     @State private var isSignUp = false
     @State private var name = ""
     @State private var email = ""
     @State private var password = ""
     @State private var confirmPassword = ""
     @State private var showPassword = false
     @State private var showConfirmPassword = false
     @StateObject private var authViewModel = AuthViewModel()

     var body: some View {
         ZStack {
             // Градиентный фон с темными оттенками
             LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                 .edgesIgnoringSafeArea(.all)
                 
             VStack(spacing: 20) {
                 // Заголовок
                 Text("Event Planning")
                     .font(.largeTitle)
                     .fontWeight(.bold)
                     .foregroundColor(.white)
                     .shadow(radius: 5)
                 
                 VStack(spacing: 16) {
                     // Ввод имени для регистрации
                     if isSignUp {
                         TextField("Name", text: $name)
                             .padding()
                             .background(Color.white.opacity(0.7))
                             .cornerRadius(10)
                             .padding(.horizontal, 20)
                     }
                     
                     // Ввод email
                     TextField("Email", text: $email)
                         .padding()
                         .background(Color.white.opacity(0.7))
                         .cornerRadius(10)
                         .padding(.horizontal, 20)
                     
                     // Ввод пароля
                     SecureField("Password", text: $password)
                         .padding()
                         .background(Color.white.opacity(0.7))
                         .cornerRadius(10)
                         .padding(.horizontal, 20)
                     
                     // Ввод подтверждения пароля для регистрации
                     if isSignUp {
                         SecureField("Confirm Password", text: $confirmPassword)
                             .padding()
                             .background(Color.white.opacity(0.7))
                             .cornerRadius(10)
                             .padding(.horizontal, 20)
                     }
                 }
                 .padding(.top, 20)
                 
                 // Показ ошибки
                 if !authViewModel.errorMessage.isEmpty {
                     Text(authViewModel.errorMessage)
                         .foregroundColor(.red)
                         .font(.subheadline)
                         .padding()
                         .background(Color.white.opacity(0.8))
                         .cornerRadius(10)
                         .padding(.horizontal, 20)
                 }
                 
                 VStack(spacing: 12) {
                     // Кнопка для входа или регистрации
                     Button(action: {
                         withAnimation {
                             isSignUp ? signUp() : signIn()
                         }
                     }) {
                         Text(isSignUp ? "Sign Up" : "Sign In")
                             .font(.headline)
                             .frame(maxWidth: .infinity)
                             .frame(height: 50)
                             .background(Color.blue)
                             .foregroundColor(.white)
                             .cornerRadius(12)
                             .shadow(radius: 5)
                     }
                     .padding(.horizontal, 20)
                     
                     // Переключение между входом и регистрацией
                     Button(action: {
                         withAnimation {
                             isSignUp.toggle()
                         }
                     }) {
                         Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                             .font(.subheadline)
                             .foregroundColor(.white)
                             .opacity(0.7)
                     }
                 }
                 .padding(.bottom, 40)
                 
                 Spacer()
             }
             .animation(.easeInOut(duration: 0.3), value: isSignUp)
         }
     }

     // Метод регистрации
     private func signUp() {
         authViewModel.signUp(name: name, email: email, password: password, confirmPassword: confirmPassword) { success in
             if success {
                 userIsLoggedIn = true
             }
         }
     }

     // Метод входа
     private func signIn() {
         authViewModel.signIn(email: email, password: password) { success in
             if success {
                 userIsLoggedIn = true
             }
         }
     }
 }

 #Preview {
     AuthView(userIsLoggedIn: .constant(false))
 }

*/
