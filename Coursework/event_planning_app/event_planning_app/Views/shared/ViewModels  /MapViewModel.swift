import SwiftUI
import CoreLocation
import MapKit
import Combine
import SocialPlanningKit

class FriendLocationCacheEntry: NSObject {
    let location: CLLocation
    let timestamp: Date
    
    init(location: CLLocation, timestamp: Date) {
        self.location = location
        self.timestamp = timestamp
    }
}

class MapViewModel: ObservableObject {
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var friendsLocations: [FriendLocation] = []
    @Published var cameraPosition: MapCameraPosition
    
    
    @Published var userName: String = "Loading..."
    @Published var userAvatar: UIImage? = nil
    @Published var friendAvatars: [String: UIImage] = [:] // аватарки друзей
    @Published var arrivedAt: Date?
    @Published var currentSpeed: Double = 0.0
    @Published var friendsSpeeds: [String: Double] = [:]  // скорости друзей
    @Published var friendsArrivedAt: [String: Date] = [:]
    
    @Published var userCreatedMeetings: [MeetingModel] = []
    @Published var acceptedMeetings: [MeetingModel] = []

    
    private let locationManager = LocationManager.shared
    private let userService: UserServiceProtocol
    private let authService: AuthServiceProtocol
    private let avatarService = AvatarService.shared
    
    private var cancellables = Set<AnyCancellable>()
    // Кеш предыдущих локаций друзей для вычисления скорости
    private var friendLocationCache = NSCache<NSString, FriendLocationCacheEntry>()
    
    // ** Новый кэш расстояний **
        private var friendDistanceCache = NSCache<NSString, NSNumber>()
        private var lastUserLocationForDistanceUpdate: CLLocation?
    
    init(
        userService: UserServiceProtocol = UserService.shared,
        authService: AuthServiceProtocol = AuthService.shared
    ) {
        self.userService = userService
        self.authService = authService
        cameraPosition = .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 53.9006, longitude: 27.5590),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
        
        // Подписка на обновления локаций друзей
        locationManager.$friendsLocations
            .sink { [weak self] friends in
                guard let self = self else { return }
                
                self.friendsLocations = friends
                self.calculateFriendsSpeeds(friends)
                // Загружаем аватарки
                self.loadFriendAvatars(friends)
                
                // Обновляем arrivedAt
                var arrivedDict: [String: Date] = [:]
                for friend in friends {
                    if let arrived = friend.arrivedAt {
                        arrivedDict[friend.id] = arrived
                    }
                }
                DispatchQueue.main.async {
                    self.friendsArrivedAt = arrivedDict
                }
                
                // Обновляем кэш расстояний после обновления локаций друзей
                if let currentCoord = self.currentLocation {
                    self.updateFriendsDistances(from: currentCoord)
                }
                
            }
            .store(in: &cancellables)
        
        // Подписка на скорость текущего пользователя
        locationManager.$currentSpeedKPH
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentSpeed)
        
        // Подписка на текущую локацию
        locationManager.$currentLocation
            .sink { [weak self] coordinate in
                self?.currentLocation = coordinate
                if let coord = coordinate {
                    self?.updateArrivedAt(for: coord)
                    self?.updateFriendsDistances(from: coord)  // Обновляем расстояния при изменении текущей локации
                }
            }
            .store(in: &cancellables)
        
        // Подписка на аватарки
        avatarService.$avatars
            .receive(on: DispatchQueue.main)
            .sink { [weak self] avatarsDict in
                guard let self = self else { return }
                self.userAvatar = avatarsDict[authService.currentUserID ?? ""]
                self.friendAvatars = avatarsDict
            }
            .store(in: &cancellables)
        
        
        
        observeUserNameChanges()
        observeAvatarChanges()
        loadMeetings()
    }
    
    func start() {
        locationManager.startLocationUpdates()
        locationManager.loadFriendsLocations()
        // Принудительное обновление расстояний, если локация уже есть
            if let coord = locationManager.currentLocation {
                currentLocation = coord
                updateFriendsDistances(from: coord, force: true)
            }
    }
    
    func stop() {
        locationManager.stopLocationUpdates()
    }
    
    func isNearby(_ friendLocation: CLLocationCoordinate2D) -> Bool {
        guard let userLocation = currentLocation else { return false }
        let userCL = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let friendCL = CLLocation(latitude: friendLocation.latitude, longitude: friendLocation.longitude)
        let distance = userCL.distance(from: friendCL)
        return distance <= 30
    }
    
    func isUserNearbyAnyFriend() -> Bool {
        friendsLocations.contains(where: { isNearby($0.coordinate) })
    }
    
    private func observeUserNameChanges() {
        guard let uid = authService.currentUserID else { return }
        userService.observeUserNameChanges(uid: uid) { [weak self] updatedName in
            DispatchQueue.main.async {
                self?.userName = updatedName
            }
        }
    }
    
    private func observeAvatarChanges() {
        guard let uid = authService.currentUserID else { return }
        
        // Дополнительно — если аватарка ещё не загружена, загружаем её
        if avatarService.avatars[uid] == nil {
            userService.getUserData(uid: uid) { user in
                if let base64 = user?.photoURL {
                    self.avatarService.loadAvatar(for: uid, base64String: base64)
                }
            }
        }
    }
    
    private func loadFriendAvatars(_ friends: [FriendLocation]) {
        for friend in friends {
            // Если аватарка для друга уже загружена — пропускаем
            if avatarService.avatars[friend.id] != nil {
                continue
            }
            
            // Иначе загружаем данные пользователя по id
            userService.getUserData(uid: friend.id) { [weak self] user in
                guard let self = self else { return }
                guard let user = user else {
                    // Если пользователя нет, очищаем аватарку
                    DispatchQueue.main.async {
                        self.friendAvatars[friend.id] = nil
                    }
                    return
                }
                if let base64 = user.photoURL {
                    self.avatarService.loadAvatar(for: user.id, base64String: base64)
                } else {
                    DispatchQueue.main.async {
                        self.friendAvatars[user.id] = nil
                    }
                }
            }
        }
    }
    
    
    func updateArrivedAt(for coordinate: CLLocationCoordinate2D) {
        guard let uid = authService.currentUserID else { return }
        userService.getUserData(uid: uid) { [weak self] user in
            guard let self = self else { return }
            if let arrivedAtDate = user?.arrivedAt {
                DispatchQueue.main.async {
                    self.arrivedAt = arrivedAtDate
                }
            }
        }
    }
    
    
    // Расчёт скорости друзей на основе изменения локаций и времени
    private func calculateFriendsSpeeds(_ friends: [FriendLocation]) {
        var updatedSpeeds: [String: Double] = [:]
        
        for friend in friends {
            let uid = friend.id
            let coordinate = friend.coordinate
            let newLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            guard let timestamp = friend.arrivedAt else {
                print("LOG: Нет времени прибытия для друга \(uid), пропускаем расчёт скорости") // LOG
                continue
            }
            
            if let previousEntry = friendLocationCache.object(forKey: uid as NSString) {
                let previousLocation = previousEntry.location
                let previousTime = previousEntry.timestamp
                
                let distance = newLocation.distance(from: previousLocation)
                let timeInterval = timestamp.timeIntervalSince(previousTime)
                
                print("LOG: Друг \(uid): расстояние = \(distance) м, время = \(timeInterval) сек") // LOG
                
                if timeInterval > 0 {
                    let speedMps = distance / timeInterval
                    let speedKph = speedMps * 3.6
                    updatedSpeeds[uid] = speedKph
                    print("LOG: Друг \(uid): вычисленная скорость = \(speedKph) км/ч") // LOG
                } else {
                    print("LOG: Друг \(uid): время между обновлениями слишком мало, скорость не вычислена") // LOG
                }
            } else {
                print("LOG: Друг \(uid): нет предыдущих данных, сохраняем текущие") // LOG
            }
            
            let newEntry = FriendLocationCacheEntry(location: newLocation, timestamp: timestamp)
            friendLocationCache.setObject(newEntry, forKey: uid as NSString)
        }
        
        DispatchQueue.main.async {
            self.friendsSpeeds = updatedSpeeds
            print("LOG: Обновлены скорости друзей: \(updatedSpeeds)") // LOG
        }
    }
    
    
    // Метод для обновления кэша расстояний с оптимизацией по порогу движения (10 метров)
    private func updateFriendsDistances(from currentLocation: CLLocationCoordinate2D, force: Bool = false) {
        let userLocation = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        
        if !force, let last = lastUserLocationForDistanceUpdate {
            let moved = userLocation.distance(from: last)
            print("LOG: Пользователь сдвинулся на \(moved) метров")
            if moved < 10 {
                print("LOG: Движение менее 10 м — обновление расстояний пропущено")
                return
            }
        } else if force {
            print("LOG: Принудительное обновление расстояний")
        } else {
            print("LOG: lastUserLocationForDistanceUpdate пустой, обновляем кэш")
        }

        lastUserLocationForDistanceUpdate = userLocation

        for friend in friendsLocations {
            let friendLocation = CLLocation(latitude: friend.coordinate.latitude, longitude: friend.coordinate.longitude)
            let distance = userLocation.distance(from: friendLocation)
            friendDistanceCache.setObject(NSNumber(value: distance), forKey: friend.id as NSString)
            print("LOG: Обновлено расстояние до друга \(friend.id): \(distance) м")
        }
    }



    // Получение расстояния до друга из кэша (если есть)
    func distanceToFriend(id: String) -> Double? {
        let distance = friendDistanceCache.object(forKey: id as NSString)?.doubleValue
        print("LOG: Запрошено расстояние до друга \(id): \(distance ?? -1) м")
        return distance
    }

    
    func loadMeetings() {
        guard let userId = authService.currentUserID else { return }
        
        let service = MeetingService()
        
        service.loadUserMeetings(userId: userId) { [weak self] userMeetings, error in
            if let userMeetings = userMeetings {
                DispatchQueue.main.async {
                    self?.userCreatedMeetings = userMeetings
                }
            }
        }
        
        service.loadAcceptedMeetings(for: userId) { [weak self] accepted, error in
            if let accepted = accepted {
                DispatchQueue.main.async {
                    self?.acceptedMeetings = accepted
                }
            }
        }
    }

    
    
    // 🔄 Общий метод для форматирования
    private func formatTimeInterval(since date: Date?) -> String {
        guard let date = date else { return "Время не доступно" }
        let interval = Date().timeIntervalSince(date)
        switch interval {
        case ..<60:
            return "Менее м"
        case ..<3600:
            return "\(Int(interval / 60))м"
        case ..<86400:
            return "\(Int(interval / 3600))ч"
        default:
            return "д"
        }
    }
    
    var timeAtLocationString: String {
        formatTimeInterval(since: arrivedAt)
    }
    
    func timeAtLocationString(for friendID: String) -> String {
        formatTimeInterval(since: friendsArrivedAt[friendID])
    }
    
}

