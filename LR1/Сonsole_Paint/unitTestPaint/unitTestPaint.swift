//
//  unitTestPaint.swift
//  unitTestPaint
//
//  Created by Artem on 5.03.25.
//

import XCTest
@testable import Сonsole_Paint

final class unitTestPaint: XCTestCase {

    
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
    
    
    // Тестируем добавление фигуры
    func testAddShape() {
        let shape = Rectangle(x: 1, y: 1, width: 3, height: 3, drawSymbol: "#", fillSymbol: " ")
        
        // Добавляем фигуру и проверяем, что она появилась
        manager.addShape(shape)
        XCTAssertEqual(manager.shapes.count, 1, "Shape should be added.")
        XCTAssertTrue(manager.isShapeWithinBounds(shape), "Shape should be within bounds.")
        
        // Попробуем добавить фигуру, которая выходит за границы
        let outOfBoundsShape = Rectangle(x: 0, y: 0, width: 15, height: 15, drawSymbol: "*", fillSymbol: nil)
        manager.addShape(outOfBoundsShape)
        
        // Проверим, что фигура не добавлена
        XCTAssertEqual(manager.shapes.count, 1, "Shape should not be added due to being out of bounds.")
        
    }

}
