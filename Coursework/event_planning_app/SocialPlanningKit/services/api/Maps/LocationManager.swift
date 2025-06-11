import CoreLocation
import MapKit
import FirebaseAuth
import Combine

public class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate, MKLocalSearchCompleterDelegate {
    public static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    private var lastUpdated: Date?
    @Published public private(set) var lastUpdatedLocation: CLLocation?
    
    @Published public var currentLocation: CLLocationCoordinate2D?
    @Published public var friendsLocations: [FriendLocation] = []
    @Published public var currentSpeedKPH: Double = 0.0
    
    private let friendService = FriendService()
    private let userService = UserService()
    
    // Для умного поиска адресов
    private let searchCompleter = MKLocalSearchCompleter()
    @Published public var searchResults: [MKLocalSearchCompletion] = []
    @Published public var searchQuery: String = "" {
        didSet {
            searchCompleter.queryFragment = searchQuery
        }
    }
    
    public override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10 // Увеличено для уменьшения лишних обновлений
        locationManager.requestWhenInUseAuthorization()
        
        // Инициализация делегата для поиска адресов
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .address
    }
    
    public  func startLocationUpdates() {
        locationManager.startUpdatingLocation()
    }
    
    public func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        
        // ✅ Вычисляем скорость в км/ч
        if location.speed >= 0 {
            let speedInKPH = location.speed * 3.6 // м/с → км/ч
            DispatchQueue.main.async {
                self.currentSpeedKPH = speedInKPH
            }
        }
        
        let hasEnoughTimePassed = lastUpdated == nil || Date().timeIntervalSince(lastUpdated!) >= 300
        let hasMovedEnough = lastUpdatedLocation == nil || lastUpdatedLocation!.distance(from: location) >= 10
        
        if hasEnoughTimePassed || hasMovedEnough {
            DispatchQueue.main.async {
                self.currentLocation = location.coordinate
            }
            
            if let currentUser = Auth.auth().currentUser {
                userService.updateUserLocation(uid: currentUser.uid, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { error in
                    if let error = error {
                        print("Error updating location: \(error.localizedDescription)")
                    } else {
                        print("Location updated: Latitude = \(location.coordinate.latitude), Longitude = \(location.coordinate.longitude)")
                    }
                }
            }
            
            lastUpdated = Date()
            lastUpdatedLocation = location // Сохраняем последнее обновленное местоположение
        }
    }
    
    public  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
    
    
    /// **Загружает местоположение друзей**
    public func loadFriendsLocations() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        friendService.getFriendsList(userID: currentUser.uid) { [weak self] friendIDs in
            guard let self = self else { return }
            print("🔄 Загружаем геопозиции для друзей: \(friendIDs)")
            
            self.friendService.getFriendsLocations(friendIDs: friendIDs) { [weak self] locations in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    print("✅ Получены координаты друзей: \(locations)")
                    self.friendsLocations = locations
                }
            }
        }
    }
    
    // MKLocalSearchCompleterDelegate
    
    public  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.searchResults = completer.results
        }
    }
    
    public  func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Ошибка поиска адреса: \(error.localizedDescription)")
    }
    
}


