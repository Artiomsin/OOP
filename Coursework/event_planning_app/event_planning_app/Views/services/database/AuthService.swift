import Firebase
import FirebaseAuth

class AuthService {
    static let shared = AuthService()
    
    // Метод для регистрации пользователя
    func signUp(name: String, email: String, password: String, confirmPassword: String, completion: @escaping (Result<FirebaseAuth.User, Error>) -> Void) {
        guard !email.isEmpty, !password.isEmpty else {
            completion(.failure(NSError(domain: "AuthService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Please fill in all fields."])))
            return
        }
        
        if password != confirmPassword {
            completion(.failure(NSError(domain: "AuthService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Passwords do not match"])))
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user {
                // После регистрации пользователя сохраняем данные в Firestore
                FirestoreService.shared.saveUserData(user: user, name: name, email: email) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(user))
                    }
                }
            }
        }
    }
    
    // Метод для входа пользователя
    func signIn(email: String, password: String, completion: @escaping (Result<FirebaseAuth.User, Error>) -> Void) {
        guard !email.isEmpty, !password.isEmpty else {
            completion(.failure(NSError(domain: "AuthService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Please fill in all fields."])))
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user {
                completion(.success(user))
            }
        }
    }
}

