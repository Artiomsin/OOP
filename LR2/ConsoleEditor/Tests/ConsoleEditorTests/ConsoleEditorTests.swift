//
//  ConsoleEditorTests.swift
import XCTest
@testable import ConsoleEditor

class FileAccessControlTests: XCTestCase {
    
    var fileAccessControl: FileAccessControl!
    
    override func setUp() {
        super.setUp()
        fileAccessControl = FileAccessControl()
    }
    
    func testGetPermission() {
        let testUser = "editor1"
        let testFile = "testFile.txt"
        
        // Присваиваем пользователю права
        fileAccessControl.setPermission(forUser: testUser, file: testFile, permission: .edit)
        
        let permission = fileAccessControl.getPermission(forUser: testUser, file: testFile)
        
        // Проверка, что пользователь имеет право редактировать
        XCTAssertTrue(permission.contains(.edit))
        XCTAssertFalse(permission.contains(.delete))
    }

    func testRemovePermission() {
        let testUser = "editor1"
        let testFile = "testFile.txt"
        
        // Присваиваем права
        fileAccessControl.setPermission(forUser: testUser, file: testFile, permission: .edit)
        
        // Удаляем права
        fileAccessControl.removePermission(forUser: testUser, file: testFile)
        
        let permission = fileAccessControl.getPermission(forUser: testUser, file: testFile)
        
        // Проверка, что права больше нет
        XCTAssertFalse(permission.contains(.edit))
    }
    
}

class MockDocument: Document {
    var content: [String]
    var fileName: String
    var fileExtension: String
    var notifier: DocumentNotifier
    
    var ownerId: String?
    
    init(fileName: String, content: [String], fileExtension: String) {
        self.fileName = fileName
        self.content = content
        self.fileExtension = fileExtension
        self.notifier = DocumentNotifier()  // Или используйте фейковый объект
    }
    
    func save() -> Bool {
        return true
    }
    
    func load() -> Bool {
        return true
    }
    
    func delete() -> Bool {
        return true
    }
    
    func displayContent() -> String {
        return content.joined(separator: "\n")
    }
    
    func saveToFirebase(userID: String, completion: @escaping (Bool) -> Void) {
        completion(true)
    }
}

class MockDocumentTests: XCTestCase {
    
    var mockDocument: MockDocument!

    override func setUp() {
        super.setUp()
        // Создаем mockDocument с некоторыми начальными значениями
        mockDocument = MockDocument(fileName: "test.txt", content: ["Hello", "World"], fileExtension: "txt")
    }

    override func tearDown() {
        mockDocument = nil
        super.tearDown()
    }

    // Тестируем правильность инициализации документа
    func testDocumentInitialization() {
        XCTAssertNotNil(mockDocument)
        XCTAssertEqual(mockDocument.fileName, "test.txt")
        XCTAssertEqual(mockDocument.content, ["Hello", "World"])
        XCTAssertEqual(mockDocument.fileExtension, "txt")
    }

    // Тестируем метод save
    func testSave() {
        let result = mockDocument.save()
        XCTAssertTrue(result, "Метод save должен возвращать true")
    }

    // Тестируем метод load
    func testLoad() {
        let result = mockDocument.load()
        XCTAssertTrue(result, "Метод load должен возвращать true")
    }

    // Тестируем метод delete
    func testDelete() {
        let result = mockDocument.delete()
        XCTAssertTrue(result, "Метод delete должен возвращать true")
    }

    // Тестируем метод displayContent
    func testDisplayContent() {
        let expectedContent = "Hello\nWorld"
        let result = mockDocument.displayContent()
        XCTAssertEqual(result, expectedContent, "Метод displayContent должен возвращать правильное содержимое документа")
    }

    // Тестируем метод saveToFirebase
    func testSaveToFirebase() {
        let expectation = self.expectation(description: "saveToFirebase")
        
        mockDocument.saveToFirebase(userID: "user123") { success in
            XCTAssertTrue(success, "Метод saveToFirebase должен успешно сохранять данные")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}
