import Foundation

class EditCommand: Command {
    private let service: StudentService
    
    init(service: StudentService) {
        self.service = service
    }
    
    func execute() {
        do {
            let students = try service.getAllStudents()
            guard !students.isEmpty else {
                print("Нет студентов для редактирования")
                return
            }
            
            print("\nСписок студентов:")
            for (index, student) in students.enumerated() {
                print("\(index + 1). \(student.name) (ID: \(student.id.uuidString.prefix(8)))")
            }
            
            print("\nВведите номер студента для редактирования:")
            guard let input = readLine(), let choice = Int(input), choice > 0, choice <= students.count else {
                print("Некорректный выбор")
                return
            }
            
            let student = students[choice - 1]
            print("Редактирование студента: \(student.name)")
            
            print("Введите новое имя (оставьте пустым для сохранения текущего):")
            let name = readLine() ?? student.name
            
            print("Введите новый возраст (оставьте пустым для сохранения текущего):")
            let ageStr = readLine()
            let age = ageStr.flatMap(Int.init) ?? student.age
            
            print("Введите новую оценку (оставьте пустым для сохранения текущего):")
            let gradeStr = readLine()
            let grade = gradeStr.flatMap(Int.init) ?? student.grade
            
            try service.editStudent(id: student.id, name: name, age: age, grade: grade)
            print("Студент успешно обновлен!")
        } catch {
            print("Ошибка при редактировании студента: \(error)")
        }
    }
}

