import Foundation

struct Student: Codable {
    let id: UUID
    var name: String
    var age: Int
    var grade: Int
    var quotes: [Quote]
    
    init(id: UUID = UUID(), name: String, age: Int, grade: Int, quotes: [Quote] = []) throws {
        guard !name.isEmpty else {
            throw ValidationError.invalidName
        }
        guard age >= 0 else {
            throw ValidationError.invalidAge
        }
        guard grade >= 0 else {
            throw ValidationError.invalidGrade
        }
        
        self.id = id
        self.name = name
        self.age = age
        self.grade = grade
        self.quotes = quotes
    }
}


