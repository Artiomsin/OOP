import XCTest
@testable import Сonsole_Paint

class unitTestCanvas: XCTestCase {

    var canvas: Canvas!
    var manager: DrawingManager!
    
    override func setUp() {
        super.setUp()
        // Создаём холст и менеджер для каждого теста
        canvas = Canvas(width: 10, height: 10)  // Подберите нужные размеры
        manager = DrawingManager(canvas: canvas)
    }
    
    override func tearDown() {
        manager = nil
        canvas = nil
        super.tearDown()
    }
    
    // Тестируем создание пустого холста
    func testEmptyCanvas() {
        let emptyCanvas = Canvas(width: 5, height: 5)
        
        // Проверяем, что на пустом холсте нет фигур
        XCTAssertEqual(emptyCanvas.pixels.flatMap { $0 }.filter { $0 != " " }.count, 0, "Canvas should be empty.")
    }
    
    // Тестируем очистку пустого холста
    func testClearEmptyCanvas() {
        // Холст пуст, очищаем его
        manager.clearCanvas()
        XCTAssertEqual(manager.shapes.count, 0, "Canvas should remain empty after clear.")
    }

    
}


