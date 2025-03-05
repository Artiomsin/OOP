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
    
    // Тестируем удаление фигуры
    func testRemoveShape() {
        let shape = Rectangle(x: 1, y: 1, width: 3, height: 3, drawSymbol: "#", fillSymbol: " ")
        manager.addShape(shape)
        
        // Удаляем фигуру и проверяем, что она удалена
        manager.removeShape(at: 0)
        XCTAssertEqual(manager.shapes.count, 0, "Shape should be removed.")
    }
    
    // Тестируем неверный индекс при удалении фигуры
    func testRemoveShapeWithInvalidIndex() {
        let shape = Rectangle(x: 1, y: 1, width: 3, height: 3, drawSymbol: "#", fillSymbol: " ")
        manager.addShape(shape)
        
        // Пробуем удалить фигуру по неверному индексу
        manager.removeShape(at: 99)
        XCTAssertEqual(manager.shapes.count, 1, "Shape should not be removed with invalid index.")
    }
    
    // Тестируем корректную работу метода `isShapeWithinBounds`
    func testShapeWithinBounds() {
        let shape = Rectangle(x: 8, y: 8, width: 3, height: 3, drawSymbol: "#", fillSymbol: " ")
        
        // Проверяем, что фигура выходит за пределы холста
        XCTAssertFalse(manager.isShapeWithinBounds(shape), "Shape should be out of bounds.")
    }
}
