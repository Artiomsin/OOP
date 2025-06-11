import SwiftUI
import UIKit
import Combine
import SocialPlanningKit

class ProfileViewModel: ObservableObject {
    
    @Published var userName: String = "Loading..."
    @Published var userEmail: String = "Loading..."
    @Published var personalInformation: String = ""
    @Published var errorMessage: String? = nil
    @Published var userUIImage: UIImage? = nil
    
    private let userService: UserServiceProtocol
    private let authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var currentUserID: String?
    
    init(
        userService: UserServiceProtocol = UserService.shared,
        authService: AuthServiceProtocol = AuthService.shared
    ) {
        self.userService = userService
        self.authService = authService
    }
    
    func loadCurrentUserData() {
           guard let userID = authService.currentUserID else {
               errorMessage = "Пользователь не авторизован"
               return
           }
           currentUserID = userID
           loadUserData(userID: userID)
       }
    
    func uploadProfileImage(_ image: UIImage) {
            guard let userID = authService.currentUserID else {
                self.errorMessage = "Не удалось получить UID"
                return
            }

            AvatarService.shared.uploadAvatar(image) { [weak self] base64 in
                guard let base64String = base64 else {
                    self?.errorMessage = "Ошибка кодирования изображения"
                    return
                }

                self?.userUIImage = image
                self?.updateUserData(field: "photoURL", value: base64String)
                AvatarService.shared.loadAvatar(for: userID, base64String: base64String)
            }
        }
    
    func loadUserData(userID: String) {
            currentUserID = userID

            userService.getUserData(uid: userID) { [weak self] userModel in
                DispatchQueue.main.async {
                    guard let user = userModel else {
                        self?.errorMessage = "Пользователь не найден"
                        return
                    }
                    
                    self?.userName = user.name
                    self?.userEmail = user.email
                    self?.personalInformation = user.personalInformation

                    if let photoString = user.photoURL {
                        AvatarService.shared.loadAvatar(for: userID, base64String: photoString)
                    }
                }
            }

            // Подписка на изображение для этого userID
            AvatarService.shared.$avatars
                .receive(on: DispatchQueue.main)
                .sink { [weak self] dict in
                    self?.userUIImage = dict[userID]
                }
                .store(in: &cancellables)
        }


    func updateUserData(field: String, value: Any) {
        guard let currentUser = authService.currentUserID else { return }
        userService.updateUserData(uid: currentUser, data: [field: value]) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Ошибка обновления \(field): \(error.localizedDescription)"
                } else {
                    switch field {
                    case "name":
                        self?.userName = value as? String ?? self?.userName ?? ""
                    case "personalInformation":
                        self?.personalInformation = value as? String ?? self?.personalInformation ?? ""
                    default:
                        break
                    }
                }
            }
        }
    }
    
    
    func updateUserName(newName: String) {
        updateUserData(field: "name", value: newName)
    }

    func updatePersonalInformation(newInfo: String) {
        updateUserData(field: "personalInformation", value: newInfo)
    }

    func updateUserStatusToOffline(completion: @escaping (Bool) -> Void) {
        updateUserData(field: "status", value: "offline")
        completion(true)
    }

    func signOut(completion: @escaping (Bool) -> Void) {
            authService.signOut { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.userName = "Loading..."
                        self?.userEmail = "Loading..."
                        self?.personalInformation = ""
                        self?.userUIImage = nil
                        completion(true)
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                        completion(false)
                    }
                }
            }
        }
}


