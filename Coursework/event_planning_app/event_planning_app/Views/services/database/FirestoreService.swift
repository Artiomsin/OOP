import FirebaseFirestore
import FirebaseAuth
import CoreLocation


class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    
    // Универсальный метод обновления данных пользователя
    func updateUserData(uid: String, data: [String: Any], completion: @escaping (Error?) -> Void) {
        let userRef = db.collection("users").document(uid)
        
        userRef.updateData(data) { error in
            completion(error)
        }
    }
    
    // Сохранение данных пользователя в Firestore
    func saveUserData(user: FirebaseAuth.User, name: String, email: String, completion: @escaping (Error?) -> Void) {
        let userRef = db.collection("users").document(user.uid)
        let userData: [String: Any] = [
            "name": name,
            "email": email,
            "photoURL": "0",  // Заглушка для URL фото
            "status": "online",  // Статус по умолчанию
            "location": GeoPoint(latitude: 0, longitude: 0),  // Заглушка для локации
            "personalInformation": "",
            "createdAt": Timestamp(date: Date()),  // Текущее время
            "friends": [], // Массив друзей
            "friendRequests": [] // Массив запросов
        ]
        
        userRef.setData(userData) { error in
            completion(error)
        }
    }
    
    
    // Получение данных пользователя из Firestore
    func getUserData(uid: String, completion: @escaping (String, String, String, String?) -> Void) {
        let userRef = db.collection("users").document(uid)
        
        userRef.getDocument { snapshot, error in
            if let error = error {
                print("Ошибка получения документа: \(error.localizedDescription)")
                completion("", "", "", nil)
            } else if let document = snapshot, document.exists {
                let data = document.data()
                
                let name = data?["name"] as? String ?? "No Name"
                let email = data?["email"] as? String ?? "No Email"
                let personalInformation = data?["personalInformation"] as? String ?? ""
                let photoURL = data?["photoURL"] as? String  // Теперь загружаем URL аватарки
                
                completion(name, email, personalInformation, photoURL)
            } else {
                print("Документ не существует")
                completion("", "", "", nil)
            }
        }
    }
    
    // Обновление местоположения пользователя
    func updateUserLocation(uid: String, latitude: Double, longitude: Double, completion: @escaping (Error?) -> Void) {
        let userRef = db.collection("users").document(uid)
        let locationData: [String: Any] = [
            "location": GeoPoint(latitude: latitude, longitude: longitude)
        ]
        
        userRef.updateData(locationData) { error in
            completion(error)
        }
    }
    
    // Слушаем изменения имени пользователя в Firestore
    func observeUserNameChanges(uid: String, completion: @escaping (String) -> Void) {
        let userRef = db.collection("users").document(uid)
        
        userRef.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot, document.exists else {
                print("Ошибка: документ не найден")
                return
            }
            
            if let name = document.data()?["name"] as? String {
                completion(name)  // Передаем обновленное имя
            }
        }
    }
    
    
    /// **Отправка запроса в друзья**
    func sendFriendRequest(fromUserID: String, toUserID: String, completion: @escaping (Error?) -> Void) {
        print("🔄 Отправка запроса в друзья: \(fromUserID) → \(toUserID)")
        let requestRef = db.collection("friend_requests").document("\(fromUserID)_\(toUserID)")
        let requestData: [String: Any] = [
            "fromUserID": fromUserID,
            "toUserID": toUserID,
            "status": "pending",
            "timestamp": Timestamp(date: Date())
        ]
        
        requestRef.setData(requestData) { error in
            if let error = error {
                print("❌ Ошибка при отправке запроса: \(error.localizedDescription)")
            } else {
                print("✅ Запрос в друзья успешно отправлен!")
            }
            completion(error)
        }
    }
    
    /// **Принятие запроса в друзья**
    func acceptFriendRequest(fromUserID: String, toUserID: String, completion: @escaping (Error?) -> Void) {
        let batch = db.batch()
        
        let userRef1 = db.collection("users").document(fromUserID)
        let userRef2 = db.collection("users").document(toUserID)
        let requestRef = db.collection("friend_requests").document("\(fromUserID)_\(toUserID)")
        
        batch.updateData(["friends": FieldValue.arrayUnion([toUserID])], forDocument: userRef1)
        batch.updateData(["friends": FieldValue.arrayUnion([fromUserID])], forDocument: userRef2)
        batch.deleteDocument(requestRef)
        
        batch.commit { error in
            if let error = error {
                print("Ошибка при принятии запроса: \(error.localizedDescription)")
            } else {
                print("✅ Друзья успешно добавлены!")
            }
            completion(error)
        }
    }
    
    /// **Отклонение запроса в друзья**
    func declineFriendRequest(fromUserID: String, toUserID: String, completion: @escaping (Error?) -> Void) {
        print("🔄 Отклонение запроса в друзья: \(fromUserID) → \(toUserID)")
        let requestRef = db.collection("friend_requests").document("\(fromUserID)_\(toUserID)")
        
        requestRef.delete { error in
            if let error = error {
                print("❌ Ошибка при отклонении запроса: \(error.localizedDescription)")
            } else {
                print("✅ Запрос успешно отклонен!")
            }
            completion(error)
        }
    }
    
    /// **Удаление из друзей**
    func removeFriend(userID: String, friendID: String, completion: @escaping (Error?) -> Void) {
        print("🔄 Удаление из друзей: \(userID) → \(friendID)")
        let userRef1 = db.collection("users").document(userID)
        let userRef2 = db.collection("users").document(friendID)
        
        userRef1.updateData(["friends": FieldValue.arrayRemove([friendID])])
        userRef2.updateData(["friends": FieldValue.arrayRemove([userID])])
        
        print("✅ Пользователь \(friendID) удален из друзей пользователя \(userID)")
        completion(nil)
    }
    
    /// **Получение списка друзей**
    func getFriendsList(userID: String, completion: @escaping ([String]) -> Void) {
        db.collection("users").document(userID).getDocument { snapshot, error in
            if let error = error {
                print("Ошибка при получении списка друзей: \(error.localizedDescription)")
                completion([])
                return
            }
            
            let friends = snapshot?.data()?["friends"] as? [String] ?? []
            print("✅ Список друзей получен: \(friends)")
            completion(friends)
        }
    }
    
    /// **Слушаем входящие заявки в друзья**
    func observeFriendRequests(userID: String, completion: @escaping ([String]) -> Void) {
        print("🔄 Подписка на заявки в друзья для: \(userID)")
        db.collection("friend_requests")
            .whereField("toUserID", isEqualTo: userID)
            .whereField("status", isEqualTo: "pending")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Ошибка при получении заявок в друзья: \(error.localizedDescription)")
                    return
                }
                
                let requests = snapshot?.documents.map { $0.data()["fromUserID"] as? String ?? "" } ?? []
                print("✅ Получены заявки в друзья: \(requests)")
                completion(requests)
            }
    }
    
    /// **Слушаем изменения в списке друзей**
    func observeFriendsChanges(userID: String, completion: @escaping ([String]) -> Void) {
        print("🔄 Подписка на изменения списка друзей: \(userID)")
        let userRef = db.collection("users").document(userID)
        
        userRef.addSnapshotListener { snapshot, error in
            guard let document = snapshot, document.exists else {
                print("❌ Ошибка: документ пользователя не найден")
                return
            }
            
            let friends = document.data()?["friends"] as? [String] ?? []
            print("✅ Обновленный список друзей: \(friends)")
            completion(friends)
        }
    }
    
    /// **Получение ID пользователя по email**
    func getUserIDByEmail(email: String, completion: @escaping (String?) -> Void) {
        print("🔄 Поиск пользователя по email: \(email)")
        db.collection("users")
            .whereField("email", isEqualTo: email.lowercased())
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Ошибка поиска пользователя: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                if let document = snapshot?.documents.first {
                    let userID = document.documentID
                    print("✅ Найден пользователь: \(userID) (email: \(email))")
                    completion(userID)
                } else {
                    print("⚠️ Пользователь с email \(email) не найден")
                    completion(nil)
                }
            }
    }
    
    
    // Получение имени пользователя по userID
    func getUserName(userID: String, completion: @escaping (String) -> Void) {
        db.collection("users").document(userID).getDocument { document, error in
            if let error = error {
                print("Ошибка при получении имени: \(error.localizedDescription)")
                completion("")
                return
            }
            
            guard let document = document, document.exists,
                  let name = document.data()?["name"] as? String else {
                print("Имя пользователя не найдено")
                completion("")
                return
            }
            
            completion(name)
        }
    }
    
    func searchUsersByEmail(query: String, completion: @escaping ([String]) -> Void) {//new**
        db.collection("users")
            .whereField("email", isGreaterThanOrEqualTo: query)
            .whereField("email", isLessThanOrEqualTo: query + "\u{f8ff}") // Используем символ для поиска по алфавиту
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Ошибка при поиске пользователей: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                var users: [String] = []
                for document in querySnapshot!.documents {
                    // Получаем email пользователя из данных документа
                    if let email = document.data()["email"] as? String {
                        users.append(email)
                    }
                }
                
                completion(users)
            }
    }
    
    
   
    func getFriendsLocations(friendIDs: [String], completion: @escaping ([FriendLocation]) -> Void) {
        guard !friendIDs.isEmpty else {
            completion([])
            return
        }

        db.collection("users").whereField(FieldPath.documentID(), in: friendIDs).getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                completion([])
                return
            }

            let locations = documents.compactMap { doc -> FriendLocation? in
                guard let name = doc.data()["name"] as? String,
                      let geoPoint = doc.data()["location"] as? GeoPoint else { return nil }
                
                return FriendLocation(
                    id: doc.documentID,
                    name: name,
                    coordinate: CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
                )
            }
            completion(locations)
        }
    }

    
    
}

/*// Обновление статуса пользователя в Firestore
 func updateUserStatus(uid: String, status: String, completion: @escaping (Error?) -> Void) {
 let userRef = db.collection("users").document(uid)
 
 userRef.updateData([
 "status": status
 ]) { error in
 completion(error)
 }
 }
 
 
 
 
 
 
 

 */
// В файле, например, MathService.swift

