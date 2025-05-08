import Foundation

struct FilePermission: OptionSet {
    let rawValue: Int
    
    static let read = FilePermission(rawValue: 1 << 0)// 1 (бит 0)
    static let edit = FilePermission(rawValue: 1 << 1)// 2 (бит 1)
    static let delete = FilePermission(rawValue: 1 << 2)// 4 (бит 2)
    static let share = FilePermission(rawValue: 1 << 3)// 8 (бит 3)
    static let managePermissions = FilePermission(rawValue: 1 << 4)// 16 (бит 4)
    static let denyRead = FilePermission(rawValue: 1 << 5)// 32 (бит 5)
    
    static let viewer: FilePermission = [.read]
    static let editor: FilePermission = [.read]
    static let owner: FilePermission = [.read, .edit, .delete, .share, .managePermissions]
    static let admin: FilePermission = [.read, .edit, .delete, .share, .managePermissions]
    
    func description() -> String {
        var desc: [String] = []
        if contains(.read) { desc.append("чтение") }
        if contains(.edit) { desc.append("редактирование") }
        if contains(.delete) { desc.append("удаление") }
        if contains(.share) { desc.append("общий доступ") }
        if contains(.managePermissions) { desc.append("управление правами") }
        if contains(.denyRead) { desc.append("запрет чтения") }
        
        return desc.isEmpty ? "нет прав" : desc.joined(separator: ", ")
    }
}
