import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

class ProfileViewModel: ObservableObject {
    @Published var userName: String = "Loading..."
    @Published var userEmail: String = "Loading..."
    @Published var personalInformation: String = ""
    @Published var errorMessage: String? = nil
    @Published var userUIImage: UIImage? = nil
    private var db = Firestore.firestore()
    
    // Загрузка данных пользователя
    func loadUserData() {
        guard let currentUser = Auth.auth().currentUser else { return }
        FirestoreService.shared.getUserData(uid: currentUser.uid) { name, email, personalInfo, photoURL in
            self.userName = name
            self.userEmail = email
            self.personalInformation = personalInfo
        }
    }
    
    // Универсальный метод обновления данных
    func updateUserData(field: String, value: Any) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        FirestoreService.shared.updateUserData(uid: currentUser.uid, data: [field: value]) { error in
            if let error = error {
                self.errorMessage = "Ошибка обновления \(field): \(error.localizedDescription)"
            } else {
                DispatchQueue.main.async {
                    switch field {
                    case "name":
                        self.userName = value as? String ?? self.userName
                        
                    case "personalInformation":
                        self.personalInformation = value as? String ?? self.personalInformation
                    default:
                        break
                    }
                }
            }
        }
    }
    
    // Обновление имени
    func updateUserName(newName: String) {
        updateUserData(field: "name", value: newName)
    }
    
    // Обновление personalInformation
    func updatePersonalInformation(newInfo: String) {
        updateUserData(field: "personalInformation", value: newInfo)
    }
    
    // Обновление статуса перед выходом
    func updateUserStatusToOffline(completion: @escaping (Bool) -> Void) {
        updateUserData(field: "status", value: "offline")
        completion(true)
    }
    
    func signOut(completion: @escaping (Bool) -> Void) {
        updateUserStatusToOffline { success in
            if success {
                do {
                    try Auth.auth().signOut()
                    DispatchQueue.main.async {
                        self.userName = "Loading..." // Очистить имя после выхода
                        self.userEmail = "Loading..." // Очистить email
                        self.personalInformation = "" // Очистить личную информацию
                    }
                    completion(true)
                } catch {
                    self.errorMessage = "Ошибка выхода: \(error.localizedDescription)"
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
    }
}
