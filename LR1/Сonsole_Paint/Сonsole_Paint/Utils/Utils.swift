import Foundation

// Функция для отображения координатной плоскости с заданными размерами
func drawCoordinatePlane(width: Int, height: Int) -> Canvas {
    let canvas = Canvas(width: width, height: height)
    
    // Рисуем рамку
    for y in 0..<height {
        for x in 0..<width {
            if x == 0 || x == width - 1 || y == 0 || y == height - 1 {
                canvas.pixels[y][x] = "#"  // Рамка
            } else {
                canvas.pixels[y][x] = " "  // Пустое поле
            }
        }
    }
    
    return canvas
}

// Функция для проверки правильности ввода целого числа
func readIntInput(prompt: String) -> Int? {
    while true {
        print(prompt, terminator: " ")
        if let input = readLine(), let number = Int(input) {
            return number
        }
        print("Неверный ввод. Пожалуйста, введите целое число.")
        
    }
}

// Функция для ввода строки
func readStringInput(prompt: String) -> String? {
    print(prompt, terminator: " ")
    if let input = readLine() {
        return input
    }
    return nil
}

// Функция для ввода одного символа
func readSingleCharacterInput(prompt: String) -> Character? {
    while true {
        print(prompt, terminator: " ")
        if let input = readLine(), input.count == 1 {
            return input.first  // Возвращаем первый (и единственный) символ
        } else {
            print("Ошибка: Пожалуйста, введите только один символ.")
        }
    }
}

// Функция для ввода одного символа или пустой строки
func readSingleCharacterOrEmptyInput(prompt: String) -> Character? {
    while true {
        print(prompt, terminator: " ")
        if let input = readLine() {
            // Если введено ничего (пустая строка), возвращаем nil
            if input.isEmpty {
                return nil
            }
            // Если введено больше одного символа, выводим ошибку и просим ввести снова
            if input.count > 1 {
                print("Ошибка: Пожалуйста, введите только один символ.")
            } else {
                return input.first // Если введен ровно один символ, возвращаем его
            }
        }
    }
}

