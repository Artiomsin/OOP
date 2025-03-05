import Foundation

class DrawingManager {
    var canvas: Canvas
    var shapes: [Shape] = []
    var undoStack: [[Shape]] = []  // Стек для отмены
    var redoStack: [[Shape]] = []  // Стек для повтора
    
    init(canvas: Canvas) {
        self.canvas = canvas
    }
    
    // Сохранение состояния в стек Undo
    func saveStateForUndo() {
        let currentState = shapes.map { $0.copy() }
        undoStack.append(currentState)
        redoStack.removeAll()  // После сохранения в Undo, Redo очищается
    }
    
    // Отмена последнего действия
    func undo() {
        guard let lastState = undoStack.popLast() else {
            print("Нет состояния для отмены.")
            return
        }
        redoStack.append(shapes.map { $0.copy() })
        shapes = lastState
        redrawAllShapes()
    }
    
    // Повтор последнего отменённого действия
    func redo() {
        guard let lastState = redoStack.popLast() else {
            print("Нет состояния для повтора.")
            return
        }
        undoStack.append(shapes.map { $0.copy() })
        shapes = lastState
        redrawAllShapes()
    }
    
    func addShape(_ shape: Shape) {
        // Проверка, не выходит ли фигура за пределы холста
        if !isShapeWithinBounds(shape) {
            print("Фигура выходит за пределы холста. Пожалуйста, введите корректные данные.")
            return
        }
        saveStateForUndo()
        shapes.append(shape)
        shape.draw(on: &canvas)
        redrawAllShapes()
    }
    
    func removeShape(at index: Int) {
        if index >= 0 && index < shapes.count {
            saveStateForUndo()
            shapes[index].erase(on: &canvas)
            shapes.remove(at: index)
            restoreBorder()
            redrawAllShapes()
        } else {
            print("Неверный индекс фигуры.")
            return // Не перерисовываем холст при неверном индексе
        }
        
    }
    
    func isShapeWithinBounds(_ shape: Shape) -> Bool {
        if let rectangle = shape as? Rectangle {
            // Проверяем, не выходит ли прямоугольник за пределы холста
            return rectangle.x >= 0 && rectangle.y >= 0 &&
            rectangle.x + rectangle.width <= canvas.width && rectangle.y + rectangle.height <= canvas.height
        }
        
        if let triangle = shape as? Triangle {
            // Проверяем, не выходят ли вершины треугольника за пределы холста
            return triangle.x1 >= 0 && triangle.y1 >= 0 &&
            triangle.x2 >= 0 && triangle.y2 >= 0 &&
            triangle.x3 >= 0 && triangle.y3 >= 0 &&
            triangle.x1 < canvas.width && triangle.x2 < canvas.width && triangle.x3 < canvas.width &&
            triangle.y1 < canvas.height && triangle.y2 < canvas.height && triangle.y3 < canvas.height
        }
        
        if let circle = shape as? Circle {
            // Проверяем, не выходит ли круг за пределы холста
            return circle.x - circle.radius >= 0 && circle.y - circle.radius >= 0 &&
            circle.x + circle.radius < canvas.width && circle.y + circle.radius < canvas.height
        }
        
        return true
    }
    
    func clearCanvas() {
        saveStateForUndo()
        // Удаляем все фигуры
        shapes.removeAll()
        
        // Перерисовываем холст с рамкой
        canvas.clear()
        restoreBorder()
    }
    
    func restoreBorder() {
        // Восстанавливаем рамку после любых изменений на холсте
        for y in 0..<canvas.height {
            for x in 0..<canvas.width {
                if x == 0 || x == canvas.width - 1 || y == 0 || y == canvas.height - 1 {
                    canvas.pixels[y][x] = "#"  // Рамка
                }
            }
        }
    }
    
    func render() {
        canvas.render()
    }
    
    func moveShape(at index: Int, deltaX: Int, deltaY: Int) {
        if index >= 0 && index < shapes.count {
            saveStateForUndo()
            let shape = shapes[index]
            
            // Сначала удаляем фигуру с её старой позиции
            shape.erase(on: &canvas)
            
            // Создаем копию фигуры, чтобы проверить, не выйдет ли она за пределы холста после перемещения
            let newShape = shape.copy()
            newShape.move(by: deltaX, deltaY: deltaY)
            
            // Проверяем, остается ли фигура в пределах холста после перемещения
            if isShapeWithinBounds(newShape) {
                // Перемещаем фигуру
                shape.move(by: deltaX, deltaY: deltaY)
                
                // Перерисовываем все фигуры, включая перемещенную
                redrawAllShapes()
                
            } else {
                // Если перемещение невозможно, восстанавливаем исходное положение
                redrawAllShapes()
                print("Перемещение невозможно: фигура выходит за границы холста.")
            }
        } else {
            print("Неверный индекс фигуры.")
        }
    }
    
    func redrawAllShapes() {
        // Убираем все фигуры с холста
        canvas.clear()
        
        // Перерисовываем все фигуры
        for shape in shapes {
            shape.draw(on: &canvas)
            shape.fill(on: &canvas)
        }
        
        restoreBorder() // Восстанавливаем рамку после изменений
    }
    
}
