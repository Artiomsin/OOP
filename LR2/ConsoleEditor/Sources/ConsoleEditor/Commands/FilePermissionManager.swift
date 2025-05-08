import Foundation

class FilePermissionManager {
    weak var cliHandler: CLIHandler?
    weak var editor: TerminalEditor?
        
        init(cliHandler: CLIHandler, editor: TerminalEditor) {
            self.cliHandler = cliHandler
            self.editor = editor
        }
    
     func manageFilePermissions() {
        guard cliHandler?.currentUser?.canManagePermissions() == true else {
            print("У вас нет прав для управления разрешениями файлов.")
            return
        }
        
         guard let currentFile = editor?.currentDocument?.fileName else {
            print("Нет открытого файла.")
            return
        }
        
        while true {
            cliHandler?.clearScreen()
            print("""
            
            ==== УПРАВЛЕНИЕ ПРАВАМИ ДОСТУПА ====
            Текущий файл: \(currentFile)
            1. Просмотр текущих прав
            2. Добавить/изменить права
            3. Удалить права
            4. Назад
            ===================================
            Введите команду:
            """, terminator: " ")
            
            guard let input = readLine() else { continue }
            
            switch input {
            case "1": listFilePermissions(for: currentFile)
            case "2": addOrEditFilePermission(for: currentFile)
            case "3": removeFilePermission(for: currentFile)
            case "4": return
            default: print("Неверная команда.")
            }
        }
    }
    
    private func listFilePermissions(for filename: String) {
           cliHandler?.clearScreen()
           print("=== ТЕКУЩИЕ ПРАВА ДОСТУПА ДЛЯ ФАЙЛА '\(filename)' ===")
           
           guard let permissions = cliHandler?.fileAccessControl.getAllPermissions(for: filename) else {
               print("Ошибка при получении прав доступа.")
               print("\nНажмите Enter для продолжения...")
               _ = readLine()
               return
           }
           
           if permissions.isEmpty {
               print("Нет специальных прав доступа. Применяются стандартные права по ролям.")
           } else {
               for (username, permission) in permissions {
                   print("\(username): \(permissionDescription(permission))")
               }
           }
           
           print("\nНажмите Enter для продолжения...")
           _ = readLine()
       }
    
    private func addOrEditFilePermission(for filename: String) {
            cliHandler?.clearScreen()
            print("=== ДОБАВЛЕНИЕ/ИЗМЕНЕНИЕ ПРАВ ДОСТУПА ===")
            
        guard let users = cliHandler?.userManager.users else {
                print("Ошибка: список пользователей недоступен.")
                return
            }
            
            print("Доступные пользователи:")
            for (index, user) in users.enumerated() {
                print("\(index + 1). \(user.username) (\(user.roleString))")
            }
            
            print("Введите номер пользователя или имя:", terminator: " ")
            guard let input = readLine(), !input.isEmpty else {
                print("Отменено.")
                return
            }
        
        let selectedUser: User?
        if let index = Int(input), index > 0, index <= users.count {
                    selectedUser = users[index - 1]
                } else if let user = users.first(where: { $0.username.lowercased() == input.lowercased() }) {
                    selectedUser = user
                } else {
                    print("Пользователь не найден.")
                    return
                }
        
        guard let user = selectedUser else { return }
        
        print("""
        Выберите уровень доступа:
        1 - Только чтение
        2 - Чтение и редактирование
        3 - Полный доступ (чтение, редактирование, удаление)
        4 - Настраиваемые права
        Введите номер:
        """, terminator: " ")
        
        guard let choice = readLine(), let level = Int(choice) else {
            print("Некорректный ввод.")
            return
        }
        
        var permission: FilePermission
        switch level {
        case 1: permission = .viewer
        case 2: permission = .editor
        case 3: permission = .owner
        case 4:
            permission = []
            print("""
            Выберите права (можно несколько через запятую):
            1 - Чтение
            2 - Редактирование
            3 - Удаление
            4 - Управление правами
            Введите номера:
            """, terminator: " ")
            
            guard let rightsInput = readLine() else { return }
            let rights = rightsInput.components(separatedBy: ",").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
            
            for right in rights {
                switch right {
                case 1: permission.insert(.read)
                case 2: permission.insert(.edit)
                case 3: permission.insert(.delete)
                case 4: permission.insert(.managePermissions)
                default: break
                }
            }
        default:
            print("Некорректный выбор.")
            return
        }
        
        cliHandler?.fileAccessControl.setPermission(forUser: user.username, file: filename, permission: permission)
        print("Права для пользователя \(user.username) успешно установлены: \(permissionDescription(permission))")
    }
    
    private func removeFilePermission(for filename: String) {
            cliHandler?.clearScreen()
            print("=== УДАЛЕНИЕ ПРАВ ДОСТУПА ===")
            
            guard let permissions = cliHandler?.fileAccessControl.getAllPermissions(for: filename) else {
                print("Ошибка при получении прав доступа.")
                print("\nНажмите Enter для продолжения...")
                _ = readLine()
                return
            }
            
            if permissions.isEmpty {
                print("Нет специальных прав доступа для этого файла.")
                print("\nНажмите Enter для продолжения...")
                _ = readLine()
                return
            }
            
            print("Текущие права доступа для файла '\(filename)':")
            for (index, (username, _)) in Array(permissions).enumerated() {
                print("\(index + 1). \(username)")
            }
            
            print("Введите номер пользователя для удаления прав:", terminator: " ")
            guard let input = readLine(), let index = Int(input), index > 0, index <= permissions.count else {
                print("Некорректный ввод.")
                return
            }
            
            let username = Array(permissions.keys)[index - 1]
            cliHandler?.fileAccessControl.removePermission(forUser: username, file: filename)
            print("Права для пользователя \(username) удалены.")
        }
    
    private func permissionDescription(_ permission: FilePermission) -> String {
        var desc: [String] = []
        if permission.contains(.read) { desc.append("чтение") }
        if permission.contains(.edit) { desc.append("редактирование") }
        if permission.contains(.delete) { desc.append("удаление") }
        if permission.contains(.share) { desc.append("общий доступ") }
        if permission.contains(.managePermissions) { desc.append("управление правами") }
        
        return desc.isEmpty ? "нет прав" : desc.joined(separator: ", ")
    }
    
}
