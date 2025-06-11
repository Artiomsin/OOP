import FirebaseFirestore
import CoreLocation

public class FriendService: FriendServiceProtocol {
   public static let shared = FriendService()
    private let db = Firestore.firestore()

    public func sendFriendRequest(fromUserID: String, toUserID: String, completion: @escaping (Error?) -> Void) {
        print("➡️ [FriendService] Отправка заявки в друзья от '\(fromUserID)' к '\(toUserID)'")
        let requestRef = db.collection("friend_requests").document("\(fromUserID)_\(toUserID)")
        let requestData: [String: Any] = [
            "fromUserID": fromUserID,
            "toUserID": toUserID,
            "status": "pending",
            "timestamp": Timestamp(date: Date())
        ]
        
        requestRef.setData(requestData) { error in
            if let error = error {
                print("❌ [FriendService] Ошибка отправки заявки в друзья: \(error.localizedDescription)")
            } else {
                print("✅ [FriendService] Заявка успешно отправлена от '\(fromUserID)' к '\(toUserID)'")
            }
            completion(error)
        }
    }
    
  public func acceptFriendRequest(fromUserID: String, toUserID: String, completion: @escaping (Error?) -> Void) {
        print("✅ [FriendService] Принятие заявки в друзья: от '\(fromUserID)' к '\(toUserID)'")
        let batch = db.batch()
        
        let userRef1 = db.collection("users").document(fromUserID)
        let userRef2 = db.collection("users").document(toUserID)
        let requestRef = db.collection("friend_requests").document("\(fromUserID)_\(toUserID)")
        
        batch.updateData(["friends": FieldValue.arrayUnion([toUserID])], forDocument: userRef1)
        batch.updateData(["friends": FieldValue.arrayUnion([fromUserID])], forDocument: userRef2)
        batch.deleteDocument(requestRef)
        
        batch.commit { error in
            if let error = error {
                print("❌ [FriendService] Ошибка принятия заявки: \(error.localizedDescription)")
            } else {
                print("✅ [FriendService] Заявка успешно принята, пользователи стали друзьями")
            }
            completion(error)
        }
    }
    
    public  func declineFriendRequest(fromUserID: String, toUserID: String, completion: @escaping (Error?) -> Void) {
        print("🚫 [FriendService] Отклонение заявки в друзья: от '\(fromUserID)' к '\(toUserID)'")
        let requestRef = db.collection("friend_requests").document("\(fromUserID)_\(toUserID)")
        requestRef.delete { error in
            if let error = error {
                print("❌ [FriendService] Ошибка отклонения заявки: \(error.localizedDescription)")
            } else {
                print("✅ [FriendService] Заявка отклонена успешно")
            }
            completion(error)
        }
    }
    
    public func removeFriend(userID: String, friendID: String, completion: @escaping (Error?) -> Void) {
        print("🔄 [FriendService] Удаление из друзей: пользователь '\(userID)' удаляет '\(friendID)'")
        let userRef1 = db.collection("users").document(userID)
        let userRef2 = db.collection("users").document(friendID)
        
        let batch = db.batch()
        batch.updateData(["friends": FieldValue.arrayRemove([friendID])], forDocument: userRef1)
        batch.updateData(["friends": FieldValue.arrayRemove([userID])], forDocument: userRef2)
        
        batch.commit { error in
            if let error = error {
                print("❌ [FriendService] Ошибка удаления из друзей: \(error.localizedDescription)")
            } else {
                print("✅ [FriendService] Пользователь '\(friendID)' удалён из друзей пользователя '\(userID)'")
            }
            completion(error)
        }
    }
    
    public func getFriendsList(userID: String, completion: @escaping ([String]) -> Void) {
        print("📋 [FriendService] Получение списка друзей для пользователя '\(userID)'")
        db.collection("users").document(userID).getDocument { snapshot, error in
            if let error = error {
                print("❌ [FriendService] Ошибка получения списка друзей: \(error.localizedDescription)")
                completion([])
                return
            }
            
            if let data = snapshot?.data() {
                let friends = data["friends"] as? [String] ?? []
                print("✅ [FriendService] Список друзей получен, всего: \(friends.count)")
                completion(friends)
            } else {
                print("⚠️ [FriendService] Данные пользователя '\(userID)' не найдены")
                completion([])
            }
        }
    }
    
    public func observeFriendRequests(userID: String, completion: @escaping ([String]) -> Void) {
        print("👀 [FriendService] Подписка на входящие заявки в друзья для пользователя '\(userID)'")
        db.collection("friend_requests")
            .whereField("toUserID", isEqualTo: userID)
            .whereField("status", isEqualTo: "pending")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ [FriendService] Ошибка при подписке на заявки: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                if let documents = snapshot?.documents {
                    let requests = documents.compactMap { $0.data()["fromUserID"] as? String }
                    print("📥 [FriendService] Получено новых заявок: \(requests.count)")
                    completion(requests)
                } else {
                    print("⚠️ [FriendService] Нет новых заявок")
                    completion([])
                }
            }
    }
    
    public func observeFriendsChanges(userID: String, completion: @escaping ([String]) -> Void) {
        print("👀 [FriendService] Подписка на изменения списка друзей для пользователя '\(userID)'")
        let userRef = db.collection("users").document(userID)
        userRef.addSnapshotListener { snapshot, error in
            if let error = error {
                print("❌ [FriendService] Ошибка подписки на друзей: \(error.localizedDescription)")
                completion([])
                return
            }
            
            if let data = snapshot?.data() {
                let friends = data["friends"] as? [String] ?? []
                print("🔄 [FriendService] Обновление списка друзей, найдено: \(friends.count)")
                completion(friends)
            } else {
                print("⚠️ [FriendService] Данные пользователя '\(userID)' отсутствуют при обновлении друзей")
                completion([])
            }
        }
    }
    
    public func getFriendsLocations(friendIDs: [String], completion: @escaping ([FriendLocation]) -> Void) {
        print("📍 [FriendService] Получение локаций для друзей: \(friendIDs)")
        guard !friendIDs.isEmpty else {
            print("⚠️ [FriendService] Список друзей пуст, локации не запрашиваются")
            completion([])
            return
        }

        db.collection("users").whereField(FieldPath.documentID(), in: friendIDs).getDocuments { snapshot, error in
            if let error = error {
                print("❌ [FriendService] Ошибка получения локаций: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("⚠️ [FriendService] Нет данных для локаций друзей")
                completion([])
                return
            }

            let locations = documents.compactMap { doc -> FriendLocation? in
                guard let name = doc.data()["name"] as? String,
                      let geoPoint = doc.data()["location"] as? GeoPoint else {
                    print("⚠️ [FriendService] Невозможно получить локацию для друга с id \(doc.documentID)")
                    return nil
                }
                // Получаем время прибытия (arrivedAt), если есть
                            let arrivedTimestamp = doc.data()["arrivedAt"] as? Timestamp
                            let arrivedAtDate = arrivedTimestamp?.dateValue()
                
                return FriendLocation(
                    id: doc.documentID,
                    name: name,
                    coordinate: CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude),
                    arrivedAt: arrivedAtDate
                )
            }
            print("✅ [FriendService] Получено локаций друзей: \(locations.count)")
            completion(locations)
        }
    }
}

