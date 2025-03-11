import Foundation

class DrawingManager {
    var canvas: Canvas
    var shapes: [Shape] = []
    var undoStack: [[Shape]] = []
    var redoStack: [[Shape]] = []

    init(canvas: Canvas) {
        self.canvas = canvas
    }

    // Сохранение состояния в стек Undo
    func saveStateForUndo() {
        let currentState = shapes.map { $0.copy() }
        undoStack.append(currentState)
        redoStack.removeAll()
    }

    // Отмена действия
    func undo() {
        guard let lastState = undoStack.popLast() else {
            print("Нет состояния для отмены.")
            return
        }
        redoStack.append(shapes.map { $0.copy() })
        shapes = lastState
        redrawAllShapes()
    }

    // Повтор действия
    func redo() {
        guard let lastState = redoStack.popLast() else {
            print("Нет состояния для повтора.")
            return
        }
        undoStack.append(shapes.map { $0.copy() })
        shapes = lastState
        redrawAllShapes()
    }

    // Добавление фигуры
    func addShape(_ shape: Shape) {
        if !isShapeWithinBounds(shape) {
            print("Фигура выходит за пределы холста. Введите корректные данные.")
            return
        }
        saveStateForUndo()
        shapes.append(shape)
        redrawAllShapes()
    }

    // Удаление фигуры по индексу
    func removeShape(at index: Int) {
        guard index >= 0, index < shapes.count else {
            print("Неверный индекс фигуры.")
            return
        }
        saveStateForUndo()
        shapes.remove(at: index)
        redrawAllShapes()
    }

    // Очистка холста
    func clearCanvas() {
        saveStateForUndo()
        shapes.removeAll()
        canvas.clear()
        restoreBorder()
    }

    // Перемещение фигуры
    func moveShape(at index: Int, deltaX: Int, deltaY: Int) {
        guard index >= 0, index < shapes.count else {
            print("Неверный индекс фигуры.")
            return
        }

        saveStateForUndo()
        let shape = shapes[index]

        let newShape = shape.copy()
        newShape.move(by: deltaX, deltaY: deltaY)

        if isShapeWithinBounds(newShape) {
            shape.move(by: deltaX, deltaY: deltaY)
            redrawAllShapes()
        } else {
            print("Перемещение невозможно: фигура выходит за границы холста.")
        }
    }

    // Проверка выхода фигуры за границы холста
    func isShapeWithinBounds(_ shape: Shape) -> Bool {
        let pixels = shape.calculatePixelsToDraw() + shape.calculatePixelsToFill()
        return pixels.allSatisfy { (x, y) in
            x >= 0 && x < canvas.width && y >= 0 && y < canvas.height
        }
    }

    // Восстановление рамки
    func restoreBorder() {
        for y in 0..<canvas.height {
            for x in 0..<canvas.width {
                if x == 0 || x == canvas.width - 1 || y == 0 || y == canvas.height - 1 {
                    canvas.pixels[canvas.height - 1 - y][x] = "#"
                }
            }
        }
    }

    // Перерисовка всех фигур
    func redrawAllShapes() {
        canvas.clear()
        for shape in shapes {
            drawShape(shape)
        }
        restoreBorder()
    }

    // Отрисовка фигуры на холсте
    func drawShape(_ shape: Shape) {
        for (x, y) in shape.calculatePixelsToDraw() {
            if x >= 0, x < canvas.width, y >= 0, y < canvas.height {
                canvas.pixels[canvas.height - 1 - y][x] = shape.drawSymbol
            }
        }
        if let fillSymbol = shape.fillSymbol {
            for (x, y) in shape.calculatePixelsToFill() {
                if x >= 0, x < canvas.width, y >= 0, y < canvas.height {
                    canvas.pixels[canvas.height - 1 - y][x] = fillSymbol
                }
            }
        }
    }

    // Вывод холста
    func render() {
        canvas.render()
    }
}


