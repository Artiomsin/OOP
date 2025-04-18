import SwiftUI
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var errorMessage = ""
    @Published var userIsLoggedIn = false
    
    private let authService = AuthService.shared
    private let firestoreService = FirestoreService.shared  // FirestoreService уже обновлен
    
    // Метод регистрации пользователя
    func signUp(name: String, email: String, password: String, confirmPassword: String, completion: @escaping (Bool) -> Void) {
        authService.signUp(name: name, email: email, password: password, confirmPassword: confirmPassword) { result in
            switch result {
            case .success(_):
                self.userIsLoggedIn = true
                completion(true)
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                completion(false)
            }
        }
    }

    // Метод входа пользователя
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        authService.signIn(email: email, password: password) { result in
            switch result {
            case .success(_):
                self.userIsLoggedIn = true
                self.updateUserData(field: "status", value: "online")  // Обновляем статус через универсальный метод
                completion(true)
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                completion(false)
            }
        }
    }
    
    // Универсальный метод обновления данных пользователя
    private func updateUserData(field: String, value: Any) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        firestoreService.updateUserData(uid: currentUser.uid, data: [field: value]) { error in
            if let error = error {
                print("❌ Ошибка обновления \(field): \(error.localizedDescription)")
            } else {
                print("✅ \(field) успешно обновлено на \(value)")
            }
        }
    }
}

