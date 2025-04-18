import FirebaseFirestore
import FirebaseAuth
import CoreLocation

struct FriendLocation: Identifiable {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
}
