import Foundation

// Менеджер для работы с файлами (сохранение/загрузка)
class FileManager {
    // Сохранение состояния в файл
    static func saveToFile(canvas: Canvas, fileName: String) {
        print("Введите путь для сохранения файла:")
        if let directoryPath = readLine(), !directoryPath.isEmpty {
            let filePath = directoryPath + "/" + fileName
            
            var canvasString = ""
            for row in canvas.pixels {
                canvasString += String(row) + "\n"
            }
            
            do {
                try canvasString.write(toFile: filePath, atomically: true, encoding: .utf8)
                print("Холст сохранен в \(filePath)")
            } catch {
                print("Не удалось сохранить холст: \(error)")
            }
        } else {
            print("Некорректный путь. Сохранение отменено.")
        }
    }
    
    // Загрузка состояния из файла
    static func loadFromFile(canvas: inout Canvas, fileName: String) {
        print("Введите путь к файлу для загрузки:")
        if let directoryPath = readLine(), !directoryPath.isEmpty {
            let filePath = directoryPath + "/" + fileName
            
            let fileManager = Foundation.FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                do {
                    let canvasString = try String(contentsOfFile: filePath, encoding: .utf8)
                    
                    var rows = canvasString.split(separator: "\n")
                    if rows.last?.isEmpty == true {
                        rows.removeLast() // Убираем лишний символ новой строки
                    }
                    
                    canvas.clear() // Очищаем холст перед загрузкой
                    
                    for (y, row) in rows.enumerated() {
                        for (x, char) in row.enumerated() {
                            if x < canvas.width && y < canvas.height {
                                canvas.pixels[canvas.height - 1 - y][x] = char
                            }
                        }
                    }
                    
                    print("Холст загружен из \(filePath)")
                    canvas.render() // Отображаем холст после загрузки
                } catch {
                    print("Не удалось загрузить холст: \(error)")
                }
            } else {
                print("Файл не существует в \(filePath)")
            }
        } else {
            print("Некорректный путь. Загрузка отменена.")
        }
    }
}


