import Foundation

struct StudentFactory {
    static func create(from dto: StudentDTO) throws -> Student {
        guard let id = UUID(uuidString: dto.id) else {
            throw ValidationError.invalidName
        }
        let quotes = dto.quotes.map { QuoteFactory.create(from: $0) }
        return try Student(id: id, name: dto.name, age: dto.age, grade: dto.grade, quotes: quotes)
    }
    
    static func createDTO(from student: Student) -> StudentDTO {
        let quoteDTOs = student.quotes.map { QuoteFactory.createDTO(from: $0) }
        return StudentDTO(
            id: student.id.uuidString,
            name: student.name,
            age: student.age,
            grade: student.grade,
            quotes: quoteDTOs
        )
    }
}


