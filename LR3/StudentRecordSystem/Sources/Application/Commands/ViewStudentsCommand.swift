import Foundation

class ViewCommand: Command {
    private let service: StudentService
    
    init(service: StudentService) {
        self.service = service
    }
    
    func execute() {
        do {
            let students = try service.getAllStudents()
            guard !students.isEmpty else {
                print("Нет студентов для отображения")
                return
            }
            
            print("\nСписок студентов:")
            for student in students {
                print("""
                Имя: \(student.name)
                Возраст: \(student.age)
                Оценка: \(student.grade)
                ID: \(student.id.uuidString.prefix(8))
                Количество цитат: \(student.quotes.count)
                --------------------
                """)
            }
        } catch {
            print("Ошибка при загрузке студентов: \(error)")
        }
    }
}

class ViewQuotesCommand: Command {
    private let service: StudentService
    
    init(service: StudentService) {
        self.service = service
    }
    
    func execute() {
        do {
            let students = try service.getAllStudents()
            guard !students.isEmpty else {
                print("Нет студентов для отображения")
                return
            }
            
            print("\nСписок студентов:")
            for (index, student) in students.enumerated() {
                print("\(index + 1). \(student.name) (цитат: \(student.quotes.count))")
            }
            
            print("\nВведите номер студента для просмотра цитат:")
            guard let input = readLine(), let choice = Int(input), choice > 0, choice <= students.count else {
                print("Некорректный выбор")
                return
            }
            
            let student = students[choice - 1]
            print("\nЦитаты студента \(student.name):")
            if student.quotes.isEmpty {
                print("У студента пока нет цитат")
            } else {
                for (index, quote) in student.quotes.enumerated() {
                    print("\(index + 1). \"\(quote.text)\" — \(quote.author)")
                }
            }
        } catch {
            print("Ошибка: \(error)")
        }
    }
}

