import Foundation
import FirebaseStorage
import FirebaseFirestore

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // Функция для сохранения документа в Firestore
    func saveDocument(userID: String, fileName: String, content: [String], completion: @escaping (Bool, Error?) -> Void) {
        // Логируем начало процесса сохранения
        print("Попытка сохранить файл: \(fileName)")
        
        let documentData: [String: Any] = [
            "fileName": fileName,
            "content": content.joined(separator: "\n"),
            "uploadDate": Timestamp(date: Date()),
            "ownerId": userID
        ]
        
        // Сохраняем документ в Firestore
        db.collection("users").document(userID).collection("files").document(fileName).setData(documentData) { error in
            if let error = error {
                print("Ошибка при сохранении данных: \(error.localizedDescription)")
                completion(false, error)
                return
            }
            print("Документ успешно сохранен в Firestore.")
            completion(true, nil)
        }
    }

    // Функция для получения списка файлов для пользователя
    func listDocuments(userID: String, completion: @escaping ([String]?, Error?) -> Void) {
        db.collection("users").document(userID).collection("files").getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            let files = snapshot?.documents.compactMap { $0["fileName"] as? String }
            completion(files, nil)
        }
    }
    
    func uploadDocumentToStorage(userID: String, fileName: String, content: String, completion: @escaping (Bool, Error?) -> Void) {
            let storageRef = Storage.storage().reference().child("users/\(userID)/files/\(fileName)")

            guard let data = content.data(using: .utf8) else {
                completion(false, NSError(domain: "InvalidData", code: -1, userInfo: nil))
                return
            }

            storageRef.putData(data, metadata: nil) { metadata, error in
                if let error = error {
                    print("Ошибка при загрузке файла в Storage: \(error.localizedDescription)")
                    completion(false, error)
                } else {
                    print("Файл успешно загружен в Firebase Storage")
                    completion(true, nil)
                }
            }
        }
}

