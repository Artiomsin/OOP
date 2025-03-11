import Foundation

func main() {
    let width = 81
    let height = 41
    
    var canvas = Canvas(width: width, height: height)
    let manager = DrawingManager(canvas: canvas)
    
    while true {
        print("\n=== Главное меню ===")
        print("1: Добавить фигуру")
        print("2: Удалить фигуру")
        print("3: Очистить холст")
        print("4: Переместить фигуру")
        print("5: Сохранить холст")
        print("6: Загрузить холст")
        print("7: Отменить последнее действие")
        print("8: Повторить отменённое действие")
        print("0: Выход\n")
        
        print("Выберите действие: ", terminator: "")
        guard let input = readLine(), let action = Int(input) else {
            print("Неверный ввод. Попробуйте снова.")
            continue
        }
        
        if action == 0 {
            print("Выход из программы...")
            break
        }
        
                switch action {
                case 1:
                    print("\nВыберите фигуру: (1) Прямоугольник (2) Треугольник (3) Круг")
                    if let shapeChoice = readLine(), let shapeType = Int(shapeChoice) {
                        if let inputSymbol = readSingleCharacterInput(prompt: "Введите символ для рисования:") {
                            let fillSymbol = readSingleCharacterOrEmptyInput(prompt: "Введите символ заливки (или Enter для пропуска):")
                            
                            switch shapeType {
                            case 1:
                                if let x = readIntInput(prompt: "Введите x:"),
                                   let y = readIntInput(prompt: "Введите y:"),
                                   let width = readIntInput(prompt: "Введите ширину:"),
                                   let height = readIntInput(prompt: "Введите высоту:") {
                                    
                                    let rect = Rectangle(x: x, y: y, width: width, height: height, drawSymbol: inputSymbol, fillSymbol: fillSymbol)
                                    manager.addShape(rect)
                                }
                            case 2:
                                if let x1 = readIntInput(prompt: "Введите x1:"),
                                   let y1 = readIntInput(prompt: "Введите y1:"),
                                   let x2 = readIntInput(prompt: "Введите x2:"),
                                   let y2 = readIntInput(prompt: "Введите y2:"),
                                   let x3 = readIntInput(prompt: "Введите x3:"),
                                   let y3 = readIntInput(prompt: "Введите y3:") {
                                    
                                    let tri = Triangle(x1: x1, y1: y1, x2: x2, y2: y2, x3: x3, y3: y3, drawSymbol: inputSymbol, fillSymbol: fillSymbol)
                                    manager.addShape(tri)
                                }
                            case 3:
                                if let x = readIntInput(prompt: "Введите x:"),
                                   let y = readIntInput(prompt: "Введите y:"),
                                   let radius = readIntInput(prompt: "Введите радиус:") {
                                    
                                    let circ = Circle(x: x, y: y, radius: radius, drawSymbol: inputSymbol, fillSymbol: fillSymbol)
                                    manager.addShape(circ)
                                }
                            default:
                                print("Неверный выбор фигуры.")
                            }
                        }
                    }
                case 2:
                    if let index = readIntInput(prompt: "Введите индекс фигуры для удаления:") {
                        manager.removeShape(at: index)
                    }
                case 3:
                    manager.clearCanvas()
                    print("Холст очищен.")
                case 4:
                    if let index = readIntInput(prompt: "Введите индекс фигуры для перемещения:") {
                        var isMoving = true
                        while isMoving {
                            print("Используйте клавиши: (1) Влево (2) Вправо (3) Вверх (4) Вниз (5) Завершить перемещение")
                            if let direction = readLine() {
                                switch direction {
                                case "1": manager.moveShape(at: index, deltaX: -1, deltaY: 0)
                                case "2": manager.moveShape(at: index, deltaX: 1, deltaY: 0)
                                case "3": manager.moveShape(at: index, deltaX: 0, deltaY: 1)
                                case "4": manager.moveShape(at: index, deltaX: 0, deltaY: -1)
                                case "5": isMoving = false; print("Завершение перемещения.")
                                default: print("Неверный выбор. Повторите попытку.")
                                }
                            }
                        }
                    }
                case 5:
                    if let fileName = readStringInput(prompt: "Введите имя файла для сохранения:") {
                        FileManager.saveToFile(canvas: canvas, fileName: fileName)
                    }
                case 6:
                    if let fileName = readStringInput(prompt: "Введите имя файла для загрузки:") {
                        FileManager.loadFromFile(canvas: &canvas, fileName: fileName)
                    }
                case 7:
                    manager.undo()
                    print("Последнее действие отменено.")
                case 8:
                    manager.redo()
                    print("Отменённое действие повторено.")
                default:
                    print("Неверный выбор действия.")
                }
        
        
        print("\nРезультат:")
        manager.render()
    }
}

main()


