import XCTest
@testable import StudentRecordSystem

class MockQuoteService: QuoteService {
    override func getRandomQuote(completion: @escaping (Quote?) -> Void) {
        let mockQuote = Quote(text: "Test quote", author: "Test author")
        completion(mockQuote)
    }
}

class InMemoryStudentRepository: StudentRepository {
    private var storage: [Student] = []

    override func loadStudents() throws -> [Student] {
        return storage
    }

    override func saveStudents(_ students: [Student]) throws {
        storage = students
    }
}

class StudentValidationTests: XCTestCase {
    func testValidStudentCreation() throws {
           // Act
           let student = try Student(name: "Valid Name", age: 20, grade: 75)
           
           // Assert
           XCTAssertEqual(student.name, "Valid Name")
           XCTAssertEqual(student.age, 20)
           XCTAssertEqual(student.grade, 75)
       }
       
       func testEmptyNameThrowsError() {
           // Act & Assert
           XCTAssertThrowsError(try Student(name: "", age: 20, grade: 75)) { error in
               XCTAssertEqual(error as? ValidationError, ValidationError.invalidName)
           }
       }
       
       func testNegativeAgeThrowsError() {
           XCTAssertThrowsError(try Student(name: "John", age: -1, grade: 75)) { error in
               XCTAssertEqual(error as? ValidationError, ValidationError.invalidAge)
           }
       }
       
       func testNegativeGradeThrowsError() {
           XCTAssertThrowsError(try Student(name: "John", age: 20, grade: -5)) { error in
               XCTAssertEqual(error as? ValidationError, ValidationError.invalidGrade)
           }
       }
       
}

final class StudentServiceTests: XCTestCase {

    func testStudentValidationFailsForNegativeGrade() {
        XCTAssertThrowsError(try Student(name: "Test", age: 18, grade: -10)) { error in
            XCTAssertEqual(error as? ValidationError, .invalidGrade)
        }
    }

    func testStudentIsAddedSuccessfully() {
        let mockQuoteService = MockQuoteService()
        let mockRepository = InMemoryStudentRepository()
        let service = StudentService(repository: mockRepository, quoteService: mockQuoteService)


        let expectation = self.expectation(description: "Student added with quote")

        service.addStudent(name: "Alice", age: 20, grade: 90) { result in
            switch result {
            case .success(let quote):
                XCTAssertNotNil(quote)
                XCTAssertEqual(quote?.text, "Test quote")
                XCTAssertEqual(quote?.author, "Test author")

                let students = try! mockRepository.loadStudents()
                XCTAssertEqual(students.count, 1)
                XCTAssertEqual(students[0].name, "Alice")
                XCTAssertEqual(students[0].quotes.count, 1)
            case .failure(let error):
                XCTFail("Unexpected failure: \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testQuoteDTOParsing() throws {
        let json = """
        [
          {
            "q": "Push yourself, because no one else is going to do it for you.",
            "a": "Anonymous"
          }
        ]
        """.data(using: .utf8)!

        let quotes = try JSONDecoder().decode([QuoteDTO].self, from: json)
        XCTAssertEqual(quotes.first?.q, "Push yourself, because no one else is going to do it for you.")
        XCTAssertEqual(quotes.first?.a, "Anonymous")
    }
}
