import Foundation

class AddCommand: Command {
    private let service: StudentService
    
    init(service: StudentService) {
        self.service = service
    }
    
    func execute() {
        print("\nДобавление нового студента")
        print("Введите имя:")
        guard let name = readLine(), !name.isEmpty else {
            print("Имя не может быть пустым")
            return
        }
        
        print("Введите возраст:")
        guard let ageStr = readLine(), let age = Int(ageStr), age >= 0 else {
            print("Некорректный возраст")
            return
        }
        
        print("Введите оценку:")
        guard let gradeStr = readLine(), let grade = Int(gradeStr), grade >= 0 else {
            print("Некорректная оценка")
            return
        }
        
        service.addStudent(name: name, age: age, grade: grade) { result in
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

