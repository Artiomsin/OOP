import CoreLocation
import FirebaseAuth

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    private var lastUpdated: Date?
    @Published private(set) var lastUpdatedLocation: CLLocation?

    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var friendsLocations: [FriendLocation] = []
    
    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10 // Увеличено для уменьшения лишних обновлений
        locationManager.requestWhenInUseAuthorization()
    }

    func startLocationUpdates() {
        locationManager.startUpdatingLocation()
    }

    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        let hasEnoughTimePassed = lastUpdated == nil || Date().timeIntervalSince(lastUpdated!) >= 300
        let hasMovedEnough = lastUpdatedLocation == nil || lastUpdatedLocation!.distance(from: location) >= 10

        if hasEnoughTimePassed || hasMovedEnough {
            DispatchQueue.main.async {
                self.currentLocation = location.coordinate
            }

            if let currentUser = Auth.auth().currentUser {
                FirestoreService.shared.updateUserLocation(uid: currentUser.uid, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { error in
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

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
    
    
    /// **Загружает местоположение друзей**
    func loadFriendsLocations() {
        guard let currentUser = Auth.auth().currentUser else { return }

        FirestoreService.shared.getFriendsList(userID: currentUser.uid) { friendIDs in
            print("🔄 Загружаем геопозиции для друзей: \(friendIDs)")
            
            FirestoreService.shared.getFriendsLocations(friendIDs: friendIDs) { locations in
                DispatchQueue.main.async {
                    print("✅ Получены координаты друзей: \(locations)")
                    self.friendsLocations = locations
                }
            }
        }
    }

    
}

/**/
