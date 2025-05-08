import Foundation

class UserManager {
    var users: [User] = []
    weak var cliHandler: CLIHandler?
    var currentUser: User?
    
    // Инициализация и настройка
    init(cliHandler: CLIHandler) {
        self.cliHandler = cliHandler
        setupDefaultUsers()
    }
    
    private func setupDefaultUsers() {
        users = [
            User(username: "admin", role: .admin),
            User(username: "editor1", role: .editor(userId: UUID().uuidString)),
            User(username: "viewer1", role: .viewer)
        ]
        
        for user in users {
            cliHandler?.fileAccessControl.userRoles[user.username] = user.role
        }
    }
    
    // функция для ауентификации пользователя
    func authenticateUser() {
        cliHandler?.clearScreen()
        print("=== АВТОРИЗАЦИЯ ===")
        print("Доступные пользователи:")
        for (index, user) in users.enumerated() {
            print("\(index + 1). \(user.username) (\(user.roleString))")
        }
        print("Введите номер пользователя или имя:", terminator: " ")
        
        guard let input = readLine() else { return }
        
        if let index = Int(input), index > 0, index <= users.count {
            currentUser = users[index - 1]
        } else if let user = users.first(where: { $0.username.lowercased() == input.lowercased() }) {
            currentUser = user
        } else {
            print("Пользователь не найден. Используется гостевой доступ (только просмотр).")
            currentUser = User(username: "guest", role: .viewer)
        }
        
        // Добавляем пользователя как наблюдателя
        if let doc = editor.currentDocument {
            doc.notifier.addObserver(currentUser!)
        }
    }
    //функция управления пользователями
    func manageUsers() {
        guard currentUser?.canManageUsers() == true else {
            print("У вас нет прав для управления пользователями.")
            return
        }
        
        while true {
            cliHandler?.clearScreen()
            print("""
                
                ==== УПРАВЛЕНИЕ ПОЛЬЗОВАТЕЛЯМИ ====
                1. Список пользователей
                2. Добавить пользователя
                3. Изменить роль пользователя
                4. Удалить пользователя
                5. Назад
                ===================================
                Введите команду:
                """, terminator: " ")
            
            guard let input = readLine() else { continue }
            
            switch input {
            case "1": listUsers()
            case "2": addUser()
            case "3": changeUserRole()
            case "4": removeUser()
            case "5": return
            default: print("Неверная команда.")
            }
        }
    }
    // список пользователей
    private func listUsers() {
        cliHandler?.clearScreen()
        print("=== СПИСОК ПОЛЬЗОВАТЕЛЕЙ ===")
        for (index, user) in users.enumerated() {
            print("\(index + 1). \(user.username) (\(user.roleString))")
        }
        print("\nНажмите Enter для продолжения...")
        _ = readLine()
    }
    //добавление пользователя
    private func addUser() {
        guard currentUser?.canManageUsers() == true else {
            print("У вас нет прав для добавления пользователей.")
            return
        }
        
        cliHandler?.clearScreen()
        print("=== ДОБАВЛЕНИЕ ПОЛЬЗОВАТЕЛЯ ===")
        print("Введите имя пользователя:", terminator: " ")
        guard let username = readLine(), !username.isEmpty else {
            print("Имя пользователя не может быть пустым.")
            return
        }
        
        if users.contains(where: { $0.username.lowercased() == username.lowercased() }) {
            print("Пользователь с таким именем уже существует.")
            return
        }
        
        print("""
            Выберите роль:
            1 - Viewer (только просмотр)
            2 - Editor (редактирование своих документов)
            3 - Admin (полные права)
            Введите номер роли:
            """, terminator: " ")
        
        guard let roleInput = readLine(), let roleNum = Int(roleInput) else {
            print("Некорректный ввод.")
            return
        }
        
        let role: UserRole
        switch roleNum {
        case 1: role = .viewer
        case 2: role = .editor(userId: UUID().uuidString)
        case 3: role = .admin
        default:
            print("Некорректный номер роли.")
            return
        }
        
        let newUser = User(username: username, role: role)
        users.append(newUser)
        cliHandler?.fileAccessControl.userRoles[username] = role
        print("Пользователь \(username) успешно добавлен с ролью \(newUser.roleString).")
    }
    //изменение роли пользователя
    private func changeUserRole() {
        guard currentUser?.canManageUsers() == true else {
            print("У вас нет прав для изменения ролей пользователей.")
            return
        }
        
        cliHandler?.clearScreen()
        print("=== ИЗМЕНЕНИЕ РОЛИ ПОЛЬЗОВАТЕЛЯ ===")
        listUsers()
        print("Введите номер пользователя для изменения:", terminator: " ")
        
        guard let input = readLine(), let index = Int(input), index > 0, index <= users.count else {
            print("Некорректный ввод.")
            return
        }
        
        let user = users[index - 1]
        if user.username == currentUser?.username {
            print("Нельзя изменить роль текущего пользователя.")
            return
        }
        
        print("""
            Выберите новую роль:
            1 - Viewer (только просмотр)
            2 - Editor (редактирование своих документов)
            3 - Admin (полные права)
            Текущая роль: \(user.roleString)
            Введите номер новой роли:
            """, terminator: " ")
        
        guard let roleInput = readLine(), let roleNum = Int(roleInput) else {
            print("Некорректный ввод.")
            return
        }
        
        let newRole: UserRole
        switch roleNum {
        case 1: newRole = .viewer
        case 2:
            if case .editor(let userId) = user.role {
                newRole = .editor(userId: userId)
            } else {
                newRole = .editor(userId: UUID().uuidString)
            }
        case 3: newRole = .admin
        default:
            print("Некорректный номер роли.")
            return
        }
        
        users[index - 1] = User(username: user.username, role: newRole)
        cliHandler?.fileAccessControl.userRoles[user.username] = newRole
        print("Роль пользователя \(user.username) изменена на \(users[index - 1].roleString).")
    }
    //удаление пользователя
    private func removeUser() {
        guard currentUser?.canManageUsers() == true else {
            print("У вас нет прав для удаления пользователей.")
            return
        }
        
        cliHandler?.clearScreen()
        print("=== УДАЛЕНИЕ ПОЛЬЗОВАТЕЛЯ ===")
        listUsers()
        print("Введите номер пользователя для удаления:", terminator: " ")
        
        guard let input = readLine(), let index = Int(input), index > 0, index <= users.count else {
            print("Некорректный ввод.")
            return
        }
        
        let user = users[index - 1]
        if user.username == currentUser?.username {
            print("Нельзя удалить текущего пользователя.")
            return
        }
        
        let username = users[index - 1].username
        users.remove(at: index - 1)
        cliHandler?.fileAccessControl.userRoles.removeValue(forKey: username)
        print("Пользователь \(user.username) удален.")
    }
    
 
}
