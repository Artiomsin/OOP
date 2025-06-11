import SwiftUI
import SocialPlanningKit

final class AuthViewModel: ObservableObject {

    @Published var userIsLoggedIn: Bool = false
    @Published var errorMessage: String = ""

    private let authService: AuthServiceProtocol

       init(authService: AuthServiceProtocol = AuthService.shared) {
           self.authService = authService
       }
    
    // Регистрация нового пользователя
    func signUp(name: String, email: String, password: String, confirmPassword: String, completion: @escaping (Bool) -> Void) {
        authService.signUp(name: name, email: email, password: password, confirmPassword: confirmPassword) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.userIsLoggedIn = true
                    completion(true)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }

    // Авторизация пользователя
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        authService.signIn(email: email, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.userIsLoggedIn = true
                    completion(true)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }

    // Выход пользователя
    func signOut(completion: @escaping (Bool) -> Void) {
        authService.signOut { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.userIsLoggedIn = false
                    completion(true)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }
}

