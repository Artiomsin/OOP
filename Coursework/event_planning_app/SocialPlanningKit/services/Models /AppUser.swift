import FirebaseFirestore
import FirebaseAuth
import CoreLocation
import Foundation


public struct UserModel {
    public let id: String
    public let name: String
    public let email: String
    public let photoURL: String?
    public let status: String
    public let location: CLLocationCoordinate2D
    public let personalInformation: String
    public let createdAt: Date
    public let friends: [String]
    public let friendRequests: [String]
    public let arrivedAt: Date?

    public init?(_ document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }

        self.id = document.documentID
        self.name = data["name"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.photoURL = data["photoURL"] as? String
        self.status = data["status"] as? String ?? "offline"

        if let geo = data["location"] as? GeoPoint {
            self.location = CLLocationCoordinate2D(latitude: geo.latitude, longitude: geo.longitude)
        } else {
            self.location = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }

        self.personalInformation = data["personalInformation"] as? String ?? ""
        self.createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        self.friends = data["friends"] as? [String] ?? []
        self.friendRequests = data["friendRequests"] as? [String] ?? []
        self.arrivedAt = (data["arrivedAt"] as? Timestamp)?.dateValue()
    }
}




