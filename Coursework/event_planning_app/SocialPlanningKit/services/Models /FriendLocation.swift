import FirebaseFirestore
import FirebaseAuth
import CoreLocation

public struct FriendLocation: Identifiable {
    public let id: String
    public let name: String
    public let coordinate: CLLocationCoordinate2D
    public let arrivedAt: Date?
}

// Если нам нужно изменить или кастомизировать кодирование и декодирование
extension CLLocationCoordinate2D: Codable {
    // Преобразуем CLLocationCoordinate2D в GeoPoint для Firestore
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let geoPoint = try container.decode(GeoPoint.self)
        self.init(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
    }

    // Преобразуем CLLocationCoordinate2D обратно в GeoPoint при кодировании
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let geoPoint = GeoPoint(latitude: self.latitude, longitude: self.longitude)
        try container.encode(geoPoint)
    }
}
