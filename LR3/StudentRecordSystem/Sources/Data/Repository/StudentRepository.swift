import Foundation

class StudentRepository {
    private let fileName = "student_data.json"
    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
    }
    
    func loadStudents() throws -> [Student] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        
        let data = try Data(contentsOf: fileURL)
        let dtos = try JSONDecoder().decode([StudentDTO].self, from: data)
        return try dtos.map { try StudentFactory.create(from: $0) }
    }
    
    func saveStudents(_ students: [Student]) throws {
        let dtos = students.map { StudentFactory.createDTO(from: $0) }
        let data = try JSONEncoder().encode(dtos)
        try data.write(to: fileURL)
    }
}


