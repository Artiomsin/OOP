import Foundation


class CLI {
    private let studentService = StudentService()
    private var commands: [Command] = []
    private var isRunning = true
    
    init() {
        setupCommands()
    }
    
    private func setupCommands() {
        commands = [
            AddCommand(service: studentService),
            EditCommand(service: studentService),
            ViewCommand(service: studentService),
            ViewQuotesCommand(service: studentService)
        ]
    }
    
    func start() {
        while isRunning {
            printMenu()
            handleInput()
        }
    }
    
    private func printMenu() {
        print("""
        \nГлавное меню:
        1. Добавить студента
        2. Редактировать студента
        3. Показать всех студентов
        4. Показать цитаты студента
        0. Выход
        """)
    }
    
    private func handleInput() {
        guard let input = readLine(), let choice = Int(input) else {
            print("Некорректный ввод")
            return
        }
        
        switch choice {
        case 1...commands.count:
            commands[choice - 1].execute()
        case 0:
            isRunning = false
            print("До свидания!")
        default:
            print("Некорректный выбор")
        }
    }
}

