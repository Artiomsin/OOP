import Foundation

class Document {
    var content: String
    let filename: String

    // Постоянная директория для хранения файлов
    static let storageDirectory: URL = URL(fileURLWithPath: "/Users/artem/Downloads/unik/OOP/LR2/Console-based document editor/Console-based document editor")

    init(filename: String, content: String = "") {
        self.filename = filename
        self.content = content
    }

    func save() {
        let filePath = Document.storageDirectory.appendingPathComponent("\(filename).\(self.fileExtension)")

        do {
            try content.write(to: filePath, atomically: true, encoding: .utf8)
            print("✅ Документ сохранен: \(filePath.path)")
        } catch {
            print("❌ Ошибка при сохранении файла: \(error)")
        }
    }

    func open() {
        let filePath = Document.storageDirectory.appendingPathComponent("\(filename).\(self.fileExtension)")

        do {
            content = try String(contentsOf: filePath, encoding: .utf8)
            print("📂 Документ открыт: \(filename)\n📄 Содержимое:\n\(content)")
        } catch {
            print("❌ Ошибка при открытии файла: \(error)")
        }
    }

    func editDocument() {
        var lines = content.split(separator: "\n").map { String($0) }

        // Функция для отображения текущего содержимого
        func displayContent() {
            print("\n📄 Текущее содержимое:")
            if lines.isEmpty {
                print("   (пусто)")
            } else {
                for (index, line) in lines.enumerated() {
                    print("\(index + 1): \(line)")
                }
            }
        }

        // Отображаем начальное содержимое
        displayContent()

        while true {
            print("\nВведите команду (`e <номер> <новый текст>` - редактировать, `d <номер>` - удалить, `/exit` - выйти): ", terminator: "")
            guard let input = readLine(), !input.isEmpty else { continue }

            if input == "/exit" {
                content = lines.joined(separator: "\n")
                print("✅ Изменения сохранены.")
                return
            } else if input.starts(with: "d ") {
                let components = input.split(separator: " ")
                if components.count == 2, let lineNumber = Int(components[1]), lineNumber > 0, lineNumber <= lines.count {
                    lines.remove(at: lineNumber - 1)
                    print("🗑 Удалена строка \(lineNumber).")
                    displayContent()
                } else {
                    print("❌ Некорректный ввод. Используйте `d <номер строки>`")
                }
            } else if input.starts(with: "e ") {
                let components = input.split(separator: " ", maxSplits: 2)
                if components.count == 3, let lineNumber = Int(components[1]), lineNumber > 0, lineNumber <= lines.count {
                    lines[lineNumber - 1] = String(components[2])
                    print("✏ Изменена строка \(lineNumber).")
                    displayContent()
                } else {
                    print("❌ Некорректный ввод. Используйте `e <номер строки> <новый текст>`")
                }
            } else {
                // Если пользователь вводит текст без команды редактирования, добавляем новый абзац
                lines.append(input)
                displayContent()
            }
        }
    }


    func appendContent(newContent: String) {
        content += "\n" + newContent
        print("📝 Добавлен новый контент")
    }

    var fileExtension: String {
        return "txt"
    }
}

