import SwiftUI
import SocialPlanningKit

class FriendsViewModel: ObservableObject {
    @Published var friends: [String] = []  // Список userID друзей
    @Published var friendNames: [String] = []  // Список имен друзей
    @Published var friendRequests: [String] = []  // Список запросов в друзья
    @Published var friendRequestNames: [String] = []  // Имена пользователей, отправивших запросы
    @Published var currentUserName: String = ""  // Имя текущего пользователя
    
    @Published var searchResults: [String] = []
    
    @Published var errorMessage: String? = nil //new**
    
    private let friendService: FriendServiceProtocol
    private let userService: UserServiceProtocol
    private let authService: AuthServiceProtocol
    
    private var currentUserID: String? {
        authService.currentUserID
    }
    
    init(
        friendService: FriendServiceProtocol = FriendService.shared,
        userService: UserServiceProtocol = UserService.shared,
        authService: AuthServiceProtocol = AuthService.shared
    ) {
        self.friendService = friendService
        self.userService = userService
        self.authService = authService
        
        loadUserName()
        loadFriends()
        observeFriendRequests()
    }
    
    // Загрузка имени текущего пользователя
    func loadUserName() {
        guard let userID = currentUserID else { return }
        
        userService.getUserName(userID: userID) { [weak self] name in
            DispatchQueue.main.async {
                self?.currentUserName = name
            }
        }
    }
    
    // Загрузка списка userID друзей
    func loadFriends() {
        guard let userID = currentUserID else { return }
        friendService.getFriendsList(userID: userID) { [weak self] friends in
            DispatchQueue.main.async {
                self?.friends = friends
                self?.loadFriendNames(forUserIDs: friends)
            }
        }
    }
    
    // Загружаем имена друзей по списку userID в правильном порядке
    func loadFriendNames(forUserIDs userIDs: [String]) {
        var names: [String] = Array(repeating: "", count: userIDs.count)
        let dispatchGroup = DispatchGroup()
        
        for (index, userID) in userIDs.enumerated() {
            dispatchGroup.enter()
            userService.getUserName(userID: userID) { name in
                DispatchQueue.main.async {
                    names[index] = name
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.friendNames = names
        }
    }
    
    // Загружаем имена пользователей, отправивших запросы в друзья
    func loadFriendRequestNames(forUserIDs userIDs: [String]) {
        var names: [String] = Array(repeating: "", count: userIDs.count)
        let dispatchGroup = DispatchGroup()
        
        for (index, userID) in userIDs.enumerated() {
            dispatchGroup.enter()
            userService.getUserName(userID: userID) { name in
                DispatchQueue.main.async {
                    names[index] = name
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.friendRequestNames = names
        }
    }
    
    // Отправка запроса в друзья по email с проверками
    func sendFriendRequest(toEmail email: String) {
        guard let currentUserID = currentUserID else { return }
        
        userService.getUserIDByEmail(email: email) { [weak self] userID in
            guard let userID = userID else {
                DispatchQueue.main.async {
                    self?.errorMessage = "Пользователь с таким email не найден"
                }
                print("❌ Ошибка: Пользователь с таким email не найден")
                return
            }
            
            // Проверка: нельзя добавить самого себя
            if userID == currentUserID {
                DispatchQueue.main.async {
                    self?.errorMessage = "Вы не можете добавить самого себя в друзья"
                }
                print("❌ Ошибка: Нельзя добавить самого себя")
                return
            }
            
            // Проверка: пользователь уже в списке друзей
            if self?.friends.contains(userID) == true {
                DispatchQueue.main.async {
                    self?.errorMessage = "Этот пользователь уже у вас в друзьях"
                }
                print("❌ Ошибка: Пользователь уже в друзьях")
                return
            }
            
            // Если все проверки пройдены, отправляем запрос
            self?.friendService.sendFriendRequest(fromUserID: currentUserID, toUserID: userID) { error in
                if let error = error {
                    DispatchQueue.main.async {
                        self?.errorMessage = "Ошибка при отправке запроса: \(error.localizedDescription)"
                    }
                    print("❌ Ошибка при отправке запроса: \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        self?.errorMessage = nil
                    }
                    print("✅ Запрос отправлен успешно")
                }
            }
        }
    }
    
    
    // Подписка на входящие запросы в друзья
    func observeFriendRequests() {
        guard let currentUserID = currentUserID else { return }
        friendService.observeFriendRequests(userID: currentUserID) { [weak self] requests in
            DispatchQueue.main.async {
                self?.friendRequests = requests
                self?.loadFriendRequestNames(forUserIDs: requests)
            }
        }
    }
    
    // Принять запрос в друзья
    func acceptFriendRequest(fromUserID: String) {
        guard let currentUserID = currentUserID else { return }
        
        friendService.acceptFriendRequest(fromUserID: fromUserID, toUserID: currentUserID) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("Ошибка при добавлении в друзья: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    if let index = self.friendRequests.firstIndex(of: fromUserID) {
                        self.friendRequests.remove(at: index)
                        self.friendRequestNames.remove(at: index)
                    }
                    self.loadFriends()
                }
            }
        }
    }
    
    // Отклонить запрос в друзья
    func declineFriendRequest(fromUserID: String) {
        guard let currentUserID = currentUserID else { return }
        
        friendService.declineFriendRequest(fromUserID: fromUserID, toUserID: currentUserID) { [weak self] error in
            if let error = error {
                print("Ошибка при отклонении запроса: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    if let index = self?.friendRequests.firstIndex(of: fromUserID) {
                        self?.friendRequests.remove(at: index)
                        self?.friendRequestNames.remove(at: index)
                    }
                }
            }
        }
    }
    
    // Удаление друга
    func removeFriend(friendID: String) {
        guard let currentUserID = currentUserID else { return }
        
        friendService.removeFriend(userID: currentUserID, friendID: friendID) { [weak self] error in
            if let error = error {
                print("Ошибка при удалении друга: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self?.loadFriends()
                }
            }
        }
    }
    
    // Поиск пользователей по email (умный поиск) new**
    func searchUsersByEmail(query: String) {
        guard !query.isEmpty else {
            self.searchResults = []  // Если пустой запрос, очищаем результаты
            return
        }
        
        userService.searchUsersByEmail(query: query) { [weak self] users in
            DispatchQueue.main.async {
                if users.isEmpty {
                    self?.errorMessage = "Пользователи не найдены"
                } else {
                    self?.errorMessage = nil  // Очистка ошибки
                }
                self?.searchResults = users.map { $0.name }
            }
        }
    }
    
}


