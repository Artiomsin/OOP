// User.swift
import Foundation

enum UserRole {
    case viewer
    case editor(userId: String) // Теперь editor имеет идентификатор пользователя
    case admin
}

class User: DocumentObserver {
    let username: String
    let role: UserRole
    let userId: String
    private var accessStrategy: AccessStrategy
    var roleString: String {
        switch role {
        case .viewer: return "Viewer"
        case .editor: return "Editor"
        case .admin: return "Admin"
        }
    }
    init(username: String, role: UserRole) {
        self.username = username
        self.role = role
        self.userId = UUID().uuidString
        switch role {
        case .viewer:
            self.accessStrategy = ViewerAccessStrategy()
        case .editor:
            self.accessStrategy = EditorAccessStrategy()
        case .admin:
            self.accessStrategy = AdminAccessStrategy()
        }
    }
    
    // Реализация метода observer
    func documentChanged(_ document: Document, changeDescription: String) {
        print("\(username): Получено уведомление об изменении документа '\(document.fileName)': \(changeDescription)")
    }
    
    // Методы проверки прав
    // Методы проверки прав с учетом владельца документа
       func canCreateDocument() -> Bool {
           return accessStrategy.canCreateDocument()
       }
       
       func canEditDocument(documentOwnerId: String?) -> Bool {
           return accessStrategy.canEditDocument(documentOwnerId: documentOwnerId, currentUserId: userId)
       }
       
       func canDeleteDocument(documentOwnerId: String?) -> Bool {
           return accessStrategy.canDeleteDocument(documentOwnerId: documentOwnerId, currentUserId: userId)
       }
       
       func canSaveDocument(documentOwnerId: String?) -> Bool {
           return accessStrategy.canSaveDocument(documentOwnerId: documentOwnerId, currentUserId: userId)
       }
       
       func canSearchDocument() -> Bool {
           return accessStrategy.canSearchDocument()
       }
       
       func canManageUsers() -> Bool {
           return accessStrategy.canManageUsers()
       }
   
}
