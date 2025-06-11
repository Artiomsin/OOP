import Firebase
import FirebaseAuth


public class AuthService: AuthServiceProtocol {
    
    public static let shared = AuthService()
    private let auth = Auth.auth()
    
    public var currentUserID: String? {
            return auth.currentUser?.uid
        }
    
   public func signUp(name: String, email: String, password: String, confirmPassword: String, completion: @escaping (Result<User, Error>) -> Void) {
        print("🟡 [AuthService] signUp called")

        guard !email.isEmpty, !password.isEmpty else {
            print("❌ [AuthService] Email or password is empty")
            return completion(.failure(AuthError.emptyFields))
        }

        guard password == confirmPassword else {
            print("❌ [AuthService] Passwords do not match")
            return completion(.failure(AuthError.passwordsDoNotMatch))
        }

        auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("❌ [AuthService] Failed to create user: \(error.localizedDescription)")
                return completion(.failure(error))
            }

            guard let user = result?.user else {
                print("❌ [AuthService] User is nil after signUp")
                return completion(.failure(AuthError.unknown))
            }

            print("✅ [AuthService] User created with uid: \(user.uid)")

            UserService.shared.saveUserData(user: user, name: name, email: email) { error in
                if let error = error {
                    print("❌ [AuthService] Failed to save user data: \(error.localizedDescription)")
                    return completion(.failure(error))
                } else {
                    print("✅ [AuthService] User data saved successfully for uid: \(user.uid)")
                    return completion(.success(user))
                }
            }
        }
    }

    public func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        print("🟡 [AuthService] signIn called")

        guard !email.isEmpty, !password.isEmpty else {
            print("❌ [AuthService] Email or password is empty")
            return completion(.failure(AuthError.emptyFields))
        }

        auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("❌ [AuthService] Failed to sign in: \(error.localizedDescription)")
                return completion(.failure(error))
            }

            guard let user = result?.user else {
                print("❌ [AuthService] User is nil after signIn")
                return completion(.failure(AuthError.unknown))
            }

            print("✅ [AuthService] User signed in: \(user.uid)")

            UserService.shared.updateUserData(uid: user.uid, data: ["status": "online"]) { updateError in
                if let updateError = updateError {
                    print("⚠️ [AuthService] Failed to update online status: \(updateError.localizedDescription)")
                } else {
                    print("✅ [AuthService] User status updated to 'online'")
                }

                return completion(.success(user))
            }
        }
    }

    public func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        print("🟡 [AuthService] signOut called")

        let uid = auth.currentUser?.uid ?? ""
        if uid.isEmpty {
            print("⚠️ [AuthService] No user is currently signed in")
        }

        UserService.shared.updateUserData(uid: uid, data: ["status": "offline"]) { error in
            if let error = error {
                print("❌ [AuthService] Failed to update status to 'offline': \(error.localizedDescription)")
                return completion(.failure(error))
            }

            do {
                try self.auth.signOut()
                print("✅ [AuthService] User signed out successfully")
                return completion(.success(()))
            } catch {
                print("❌ [AuthService] Failed to sign out: \(error.localizedDescription)")
                return completion(.failure(error))
            }
        }
    }
}


public enum AuthError: LocalizedError {
    case emptyFields
    case passwordsDoNotMatch
    case unknown

    public var errorDescription: String? {
        switch self {
        case .emptyFields:
            return "Пожалуйста, заполните все поля."
        case .passwordsDoNotMatch:
            return "Пароли не совпадают."
        case .unknown:
            return "Неизвестная ошибка."
        }
    }
}
