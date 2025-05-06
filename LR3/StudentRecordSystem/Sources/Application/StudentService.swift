import Foundation

class StudentService {
    private let repository: StudentRepository
        private let quoteService: QuoteService

        init(repository: StudentRepository = StudentRepository(),
             quoteService: QuoteService = QuoteService()) {
            self.repository = repository
            self.quoteService = quoteService
        }
    
    func addStudent(name: String, age: Int, grade: Int, completion: @escaping (Result<Quote?, Error>) -> Void) {
        do {
            var students = try repository.loadStudents()
            let newStudent = try Student(name: name, age: age, grade: grade)
            students.append(newStudent)
            try repository.saveStudents(students)
            
            quoteService.getRandomQuote { [weak self] quote in
                if let quote = quote {
                    do {
                        try self?.addQuoteToStudent(studentId: newStudent.id, quote: quote)
                        completion(.success(quote))
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    completion(.success(nil))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func editStudent(id: UUID, name: String, age: Int, grade: Int) throws {
        var students = try repository.loadStudents()
        guard let index = students.firstIndex(where: { $0.id == id }) else {
            throw ValidationError.studentNotFound
        }
        students[index] = try Student(id: id, name: name, age: age, grade: grade, quotes: students[index].quotes)
        try repository.saveStudents(students)
    }
    
    func getAllStudents() throws -> [Student] {
        return try repository.loadStudents()
    }
    
    func addQuoteToStudent(studentId: UUID, quote: Quote) throws {
        var students = try repository.loadStudents()
        guard let index = students.firstIndex(where: { $0.id == studentId }) else {
            throw ValidationError.studentNotFound
        }
        students[index].quotes.append(quote)
        try repository.saveStudents(students)
    }
    
    func getStudentQuotes(studentId: UUID) throws -> [Quote] {
        let students = try repository.loadStudents()
        guard let student = students.first(where: { $0.id == studentId }) else {
            throw ValidationError.studentNotFound
        }
        return student.quotes
    }
}

