import Foundation

class AddCommand: Command {
    private let service: StudentService

    init(service: StudentService) {
        self.service = service
    }

    func execute() {
        print("\nДобавление нового студента")

        var name: String = ""
        repeat {
            print("Введите имя:")
            name = readLine() ?? ""
            if name.isEmpty {
                print("Имя не может быть пустым.")
            }
        } while name.isEmpty

        var age: Int?
        repeat {
            print("Введите возраст:")
            if let ageStr = readLine(), let parsedAge = Int(ageStr), parsedAge >= 0 {
                age = parsedAge
            } else {
                print("Некорректный возраст. Введите целое число больше или равно 0.")
            }
        } while age == nil

        var grade: Int?
        repeat {
            print("Введите оценку (0–100):")
            if let gradeStr = readLine(), let parsedGrade = Int(gradeStr), (0...100).contains(parsedGrade) {
                grade = parsedGrade
            } else {
                print("Оценка должна быть числом от 0 до 100.")
            }
        } while grade == nil

        service.addStudent(name: name, age: age!, grade: grade!) { result in
            switch result {
            case .success(let quote):
                print("\nСтудент успешно добавлен!")
                if let quote = quote {
                    print("\nМотивационная цитата для нового студента:")
                    print("\"\(quote.text)\" — \(quote.author)")
                }
            case .failure(let error):
                print("Ошибка при добавлении студента: \(error)")
            }
        }
    }
}

