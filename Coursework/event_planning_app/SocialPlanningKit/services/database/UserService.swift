import Foundation
import FirebaseFirestore
import FirebaseAuth
import CoreLocation

public class UserService: UserServiceProtocol {
    public  static let shared = UserService()
    private let db = Firestore.firestore()
    
    // Сохранение данных пользователя в Firestore
   public func saveUserData(user: FirebaseAuth.User, name: String, email: String, completion: @escaping (Error?) -> Void) {
        print("➡️ [UserService] Сохранение данных пользователя с uid: '\(user.uid)'")
        let userRef = db.collection("users").document(user.uid)
        let userData: [String: Any] = [
            "name": name,
            "email": email,
            "photoURL": "0",  // Заглушка для URL фото
            "status": "online",  // Статус по умолчанию
            "location": GeoPoint(latitude: 0, longitude: 0),  // Заглушка для локации
            "personalInformation": "",
            "createdAt": Timestamp(date: Date()),  // Текущее время
            "arrivedAt": Timestamp(date: Date()),
            "friends": [], // Массив друзей
            "friendRequests": [] // Массив запросов
        ]
        
        userRef.setData(userData) { error in
            if let error = error {
                print("❌ [UserService] Ошибка сохранения данных пользователя '\(user.uid)': \(error.localizedDescription)")
            } else {
                print("✅ [UserService] Данные пользователя '\(user.uid)' успешно сохранены")
            }
            completion(error)
        }
    }
    
   public func updateUserData(uid: String, data: [String: Any], completion: @escaping (Error?) -> Void) {
        print("🔄 [UserService] Обновление данных пользователя с uid: '\(uid)', данные: \(data.keys)")
        let userRef = db.collection("users").document(uid)
        userRef.updateData(data) { error in
            if let error = error {
                print("❌ [UserService] Ошибка обновления данных пользователя '\(uid)': \(error.localizedDescription)")
            } else {
                print("✅ [UserService] Данные пользователя '\(uid)' успешно обновлены")
            }
            completion(error)
        }
    }

    public func getUserData(uid: String, completion: @escaping (UserModel?) -> Void) {
        print("📋 [UserService] Получение данных пользователя с uid: '\(uid)'")
        let userRef = db.collection("users").document(uid)
        userRef.getDocument { snapshot, error in
            if let error = error {
                print("❌ [UserService] Ошибка получения данных пользователя '\(uid)': \(error.localizedDescription)")
                completion(nil)
            } else if let document = snapshot, document.exists {
                print("✅ [UserService] Данные пользователя '\(uid)' успешно получены")
                completion(UserModel(document))
            } else {
                print("⚠️ [UserService] Документ пользователя '\(uid)' не найден")
                completion(nil)
            }
        }
    }
    
   public func getUserIDByEmail(email: String, completion: @escaping (String?) -> Void) {
        print("🔍 [UserService] Поиск пользователя по email: '\(email)'")
        db.collection("users")
            .whereField("email", isEqualTo: email.lowercased())
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ [UserService] Ошибка поиска по email '\(email)': \(error.localizedDescription)")
                    completion(nil)
                } else if let userID = snapshot?.documents.first?.documentID {
                    print("✅ [UserService] Найден пользователь с email '\(email)': uid = '\(userID)'")
                    completion(userID)
                } else {
                    print("⚠️ [UserService] Пользователь с email '\(email)' не найден")
                    completion(nil)
                }
            }
    }
    
   public func getUserName(userID: String, completion: @escaping (String) -> Void) {
        print("📋 [UserService] Получение имени пользователя с uid: '\(userID)'")
        db.collection("users").document(userID).getDocument { document, error in
            if let error = error {
                print("❌ [UserService] Ошибка при получении имени пользователя '\(userID)': \(error.localizedDescription)")
                completion("")
                return
            }

            guard let document = document, document.exists,
                  let name = document.data()?["name"] as? String else {
                print("⚠️ [UserService] Имя пользователя '\(userID)' не найдено")
                completion("")
                return
            }

            print("✅ [UserService] Имя пользователя '\(userID)' получено: '\(name)'")
            completion(name)
        }
    }
    
   public func searchUsersByEmail(query: String, completion: @escaping ([UserModel]) -> Void) {
        print("🔍 [UserService] Поиск пользователей по email с запросом: '\(query)'")
        db.collection("users")
            .whereField("email", isGreaterThanOrEqualTo: query)
            .whereField("email", isLessThanOrEqualTo: query + "\u{f8ff}")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ [UserService] Ошибка при поиске пользователей по email '\(query)': \(error.localizedDescription)")
                    completion([])
                    return
                }

                let users = snapshot?.documents.compactMap { UserModel($0) } ?? []
                print("✅ [UserService] Найдено пользователей по запросу '\(query)': \(users.count)")
                completion(users)
            }
    }
    
  public func updateUserLocation(uid: String, latitude: Double, longitude: Double, completion: @escaping (Error?) -> Void) {
        print("📍 [UserService] Обновление локации пользователя '\(uid)' на (lat: \(latitude), lon: \(longitude))")
        
        let userRef = db.collection("users").document(uid)

        userRef.getDocument { snapshot, error in
            if let error = error {
                print("❌ Ошибка получения текущей локации: \(error.localizedDescription)")
                completion(error)
                return
            }

            guard let document = snapshot, document.exists else {
                print("⚠️ Документ пользователя '\(uid)' не найден, создаём новый с локацией и arrivedAt")
                let newData: [String: Any] = [
                    "location": GeoPoint(latitude: latitude, longitude: longitude),
                    "arrivedAt": Timestamp(date: Date())
                ]
                self.updateUserData(uid: uid, data: newData) { err in
                    if err == nil {
                        print("✅ Новый документ создан и локация с arrivedAt записаны")
                    }
                    completion(err)
                }
                return
            }

            let data = document.data()
            let prevGeo = data?["location"] as? GeoPoint
            print("ℹ️ Старая локация: \(String(describing: prevGeo))")

            let prevLocation = prevGeo.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
            let newLocation = CLLocation(latitude: latitude, longitude: longitude)
            let distance = prevLocation?.distance(from: newLocation) ?? 1000.0
            print("📏 Расстояние до новой локации: \(distance) м")

            let hasMoved = distance > 20
            var updateData: [String: Any] = [
                "location": GeoPoint(latitude: latitude, longitude: longitude)
            ]

            if hasMoved {
                updateData["arrivedAt"] = Timestamp(date: Date())
                print("✅ Пользователь переместился >30м — обновляем arrivedAt")
            } else {
                print("📍 Пользователь остался в пределах 30м — arrivedAt НЕ обновляем")
            }

            self.updateUserData(uid: uid, data: updateData) { err in
                if err == nil {
                    print("✅ Локация пользователя '\(uid)' успешно обновлена")
                } else {
                    print("❌ Ошибка обновления локации: \(err!.localizedDescription)")
                }
                completion(err)
            }
        }
    }

    // Слушаем изменения имени пользователя в Firestore
   public func observeUserNameChanges(uid: String, completion: @escaping (String) -> Void) {
        print("👀 [UserService] Подписка на изменения имени пользователя '\(uid)'")
        let userRef = db.collection("users").document(uid)
        
        userRef.addSnapshotListener { documentSnapshot, error in
            if let error = error {
                print("❌ [UserService] Ошибка при подписке на изменения имени пользователя '\(uid)': \(error.localizedDescription)")
                return
            }
            
            guard let document = documentSnapshot, document.exists else {
                print("⚠️ [UserService] Документ пользователя '\(uid)' не найден при подписке на изменения")
                return
            }
            
            if let name = document.data()?["name"] as? String {
                print("🔄 [UserService] Имя пользователя '\(uid)' обновлено: '\(name)'")
                completion(name)  // Передаем обновленное имя
            } else {
                print("⚠️ [UserService] Имя пользователя '\(uid)' отсутствует в документе")
            }
        }
    }
}

