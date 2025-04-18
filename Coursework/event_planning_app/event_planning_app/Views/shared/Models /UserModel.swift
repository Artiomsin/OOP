import Foundation
import FirebaseFirestore

struct UserModel: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var email: String
    var photoURL: String
    var status: String
    var location: GeoPoint  // Географическая точка (широта, долгота)
    var createdAt: Timestamp  // Дата регистрации пользователя
}

