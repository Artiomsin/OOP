import Foundation

class FileAccessControl {
    var filePermissions: [String: [String: FilePermission]] = [:]
    var userRoles: [String: UserRole] = [:]
    var fileOwners: [String: String] = [:]
    func setPermission(forUser username: String, file: String, permission: FilePermission) {
        if filePermissions[file] == nil {
            filePermissions[file] = [:]
        }
        filePermissions[file]?[username] = permission
    }
    
    func setOwner(for file: String, ownerUserId: String) {
        fileOwners[file] = ownerUserId
    }

    
    func getPermission(forUser username: String, file: String) -> FilePermission {
        var permission = userRoles[username]?.defaultPermissions ?? []

        // Добавим edit, если пользователь — владелец файла
        if let userRole = userRoles[username],
           case let .editor(userId) = userRole,
           let ownerId = fileOwners[file],
           userId == ownerId {
            permission.insert(.edit) // ← только владельцу даём право на edit
        }

        // Проверяем специальные права
        if let filePerms = filePermissions[file], let specialPerms = filePerms[username] {
            permission.formUnion(specialPerms)

            if specialPerms.contains(.denyRead) {
                permission.remove(.read)
            }
        }

        return permission
    }

    
    func removePermission(forUser username: String, file: String) {
        filePermissions[file]?.removeValue(forKey: username)
    }
    
    func getAllPermissions(for file: String) -> [String: FilePermission] {
        return filePermissions[file] ?? [:]
    }
    
    func hasBasePermission(forUser username: String, permission: FilePermission) -> Bool {
        return userRoles[username]?.defaultPermissions.contains(permission) ?? false
    }
}
