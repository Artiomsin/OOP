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

            var selectedIndex: Int?
            repeat {
                print("\nВведите номер студента для редактирования:")
                if let input = readLine(), let choice = Int(input), choice > 0, choice <= students.count {
                    selectedIndex = choice - 1
                } else {
                    print("Некорректный выбор.")
                }
            } while selectedIndex == nil

            let student = students[selectedIndex!]
            print("Редактирование студента: \(student.name)")

            print("Введите новое имя (оставьте пустым для сохранения текущего):")
            let nameInput = readLine()
            let name = nameInput?.isEmpty == false ? nameInput! : student.name

            print("Введите новый возраст (оставьте пустым для сохранения текущего):")
            let ageInput = readLine()
            let age = ageInput.flatMap(Int.init) ?? student.age

            var grade: Int = student.grade
            var validGrade = false
            repeat {
                print("Введите новую оценку (оставьте пустым для сохранения текущей):")
                let gradeInput = readLine()
                if gradeInput?.isEmpty ?? true {
                    validGrade = true // сохранить текущую
                } else if let parsedGrade = Int(gradeInput!), (0...100).contains(parsedGrade) {
                    grade = parsedGrade
                    validGrade = true
                } else {
                    print("Оценка должна быть числом от 0 до 100.")
                }
            } while !validGrade

            try service.editStudent(id: student.id, name: name, age: age, grade: grade)
            print("Студент успешно обновлен!")
        } catch {
            print("Ошибка при редактировании студента: \(error)")
        }
    }
}

