
// Протокол для стратегии доступа
protocol AccessStrategy {
    func canCreateDocument() -> Bool
    func canEditDocument(documentOwnerId: String?, currentUserId: String) -> Bool
       func canDeleteDocument(documentOwnerId: String?, currentUserId: String) -> Bool
       func canSaveDocument(documentOwnerId: String?, currentUserId: String) -> Bool
    func canSearchDocument() -> Bool
    func canManageUsers() -> Bool
}

// Конкретные стратегии доступа
struct ViewerAccessStrategy: AccessStrategy {
    func canCreateDocument() -> Bool { return false }
    func canEditDocument(documentOwnerId: String?, currentUserId: String) -> Bool { return false }
        func canDeleteDocument(documentOwnerId: String?, currentUserId: String) -> Bool { return false }
        func canSaveDocument(documentOwnerId: String?, currentUserId: String) -> Bool { return false }
    func canSearchDocument() -> Bool { return true }
    func canManageUsers() -> Bool { return false }
}

struct EditorAccessStrategy: AccessStrategy {
    func canCreateDocument() -> Bool { return true }
    func canEditDocument(documentOwnerId: String?, currentUserId: String) -> Bool {
            return documentOwnerId == currentUserId // Editor может редактировать только свои документы
        }
        func canDeleteDocument(documentOwnerId: String?, currentUserId: String) -> Bool {
            return documentOwnerId == currentUserId // Editor может удалять только свои документы
        }
        func canSaveDocument(documentOwnerId: String?, currentUserId: String) -> Bool {
            return documentOwnerId == currentUserId // Editor может сохранять только свои документы
        }
    func canSearchDocument() -> Bool { return true }
    func canManageUsers() -> Bool { return false }
}

struct AdminAccessStrategy: AccessStrategy {
    func canCreateDocument() -> Bool { return true }
    func canEditDocument(documentOwnerId: String?, currentUserId: String) -> Bool { return true }
        func canDeleteDocument(documentOwnerId: String?, currentUserId: String) -> Bool { return true }
        func canSaveDocument(documentOwnerId: String?, currentUserId: String) -> Bool { return true }
    func canSearchDocument() -> Bool { return true }
    func canManageUsers() -> Bool { return true }
}
