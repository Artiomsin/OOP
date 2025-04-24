
import Foundation
import FirebaseCore

class TerminalEditor {
    var currentDocument: Document?
}
// Вручную загружаем GoogleService-Info.plist
if let filePath = Bundle.module.path(forResource: "GoogleService-Info", ofType: "plist"),
   let options = FirebaseOptions(contentsOfFile: filePath) {
    // Настройка Firebase с использованием переданных настроек
    FirebaseApp.configure(options: options)
    print("✅ Firebase настроен вручную через FirebaseOptions")
} else {
    print("❌ Не удалось найти GoogleService-Info.plist в Bundle.module")
}
if let app = FirebaseApp.app() {
    print("Firebase успешно инициализирован: \(app)")
} else {
    print("Ошибка при инициализации Firebase.")
}
let editor = TerminalEditor()
let cliHandler = CLIHandler(editor: editor)

cliHandler.start()

/*
import Foundation

class terminalEditor {
    var content: [String] = [""]
    var cursorPosition: (row: Int, col: Int) = (0, 0)  // Начальная позиция курсора
    var isInInsertMode = false  // Для проверки, находимся ли мы в режиме ввода текста
    let indent = "    " // Отступ для новой строки (красная строка)
    var currentFile: String? // Текущий файл, если открыт

    func start() {
        print("Добро пожаловать в редактор. Выберите действие:")
        print("new - создать новый файл")
        print("open - открыть существующий файл")
        print("Введите команду: ", terminator: "")

        guard let action = readLine()?.lowercased() else { return }

        switch action {
        case "new":
            createNewFile()
        case "open":
            openExistingFile()
        default:
            print("Неизвестная команда. Завершаем программу.")
            return
        }
    }

    // Создание нового файла
    func createNewFile() {
        print("Введите имя нового файла (без расширения): ", terminator: "")
        guard let filename = readLine(), !filename.isEmpty else {
            print("Имя файла не может быть пустым.")
            return
        }
        content = [""]
        
        // Добавляем суффикс .txt, если пользователь не указал расширение
        if !filename.hasSuffix(".txt") {
            currentFile = filename + ".txt"
        } else {
            currentFile = filename
        }
        
        print("Создан новый файл: \(currentFile!)")
        enterModeSelection()
    }

    // Открытие существующего файла
    func openExistingFile() {
        print("Введите название файла для открытия (с расширением .txt): ", terminator: "")
        guard let filename = readLine(), !filename.isEmpty else {
            print("Имя файла не может быть пустым.")
            return
        }
        
        // Добавляем суффикс .txt, если он не указан
        let fullFilename = filename.hasSuffix(".txt") ? filename : filename + ".txt"
        
        let fileManager = FileManager.default
        let filePath = FileManager.default.currentDirectoryPath + "/" + fullFilename
        
        if fileManager.fileExists(atPath: filePath) {
            do {
                let fileContents = try String(contentsOfFile: filePath, encoding: .utf8)
                content = fileContents.components(separatedBy: "\n")
                currentFile = fullFilename
                print("Файл \(currentFile!) открыт.")
                
                // Устанавливаем курсор в начало первой строки
                cursorPosition = (row: 0, col: 0)
                
                enterModeSelection()
            } catch {
                print("Ошибка при чтении файла: \(error)")
            }
        } else {
            print("Файл не найден.")
        }
    }

    // Ввод команды для работы с документом
    func enterModeSelection() {
        while true {
            print("Выберите режим: editor/save/exit")
            print("Введите команду: ", terminator: "")
            
            guard let input = readLine()?.lowercased() else { continue }

            switch input {
            case "editor":
                startEditing()
            case "save":
                saveToFile()
            case "exit":
                print("Выход из редактора.")
                return
            default:
                print("Неизвестная команда.")
            }
        }
    }

    // Основная функция редактирования текста
    func startEditing() {
            while true {
            clearScreen()  // Очистить экран перед каждым обновлением
            displayContent() // Отображаем актуальный контент
            print("Введите команду (1 - влево, 2 - вправо, 3 - вниз, 4 - вверх, t - для ввода текста, d - удалить символ слева, /exit - выход из редактора): ", terminator: "")

            guard let input = readLine()?.lowercased() else { continue }

            switch input {
            case "1":
                moveCursorLeft()
            case "2":
                moveCursorRight()
            case "3":
                moveCursorDown()
            case "4":
                moveCursorUp()
            case "t":
                startInsertMode()
            case "d":
                deleteCharacterLeft()
            case "/exit":
                return
            default:
                print("Неизвестная команда.")
            }
        }
    }

    // Очищаем экран
    // Очищаем экран с использованием команды 'clear' через Process
    func clearScreen() {
        let task = Process()
        task.launchPath = "/usr/bin/env"  // Используем /usr/bin/env для корректного выполнения
        task.arguments = ["clear"]  // Команда для очистки экрана
        task.launch()  // Запуск команды
        task.waitUntilExit()  // Ожидание завершения команды перед продолжением выполнения

        // Перемещаем курсор в начало экрана
        print("\u{001B}[H", terminator: "")
        fflush(stdout)  // Сбрасываем вывод, чтобы обновления сразу появились
    }



    // Отображаем контент с курсором
    func displayContent() {
        print("Редактор документа. Для выхода введите /exit.")
        if let currentFile = currentFile {
               print("Редактируемый файл: \(currentFile)")
           }
        print(String(repeating: "=", count: 50))
        for (index, line) in content.enumerated() {
            if index == cursorPosition.row {
                let cursorLine = line.prefix(cursorPosition.col) + "|" + line.suffix(line.count - cursorPosition.col)
                print(cursorLine)
            } else {
                print(line)
            }
        }
        print(String(repeating: "=", count: 50))
    }

    // Перемещение курсора влево
    func moveCursorLeft() {
        if cursorPosition.col > 0 {
            cursorPosition.col -= 1
        }
    }

    // Перемещение курсора вправо
    func moveCursorRight() {
        let currentLine = content[cursorPosition.row]
        if cursorPosition.col < currentLine.count {
            cursorPosition.col += 1
        } else {
            content[cursorPosition.row] = currentLine + " "
            cursorPosition.col += 1
        }
    }

    // Перемещение курсора вниз
    func moveCursorDown() {
        // Проверка, не находимся ли мы на последней строке
        if cursorPosition.row < content.count - 1 {
            cursorPosition.row += 1
            // Если следующая строка не пуста, ставим курсор в конец
            if !content[cursorPosition.row].isEmpty {
                cursorPosition.col = content[cursorPosition.row].count
            } else {
                cursorPosition.col = 0  // Если строка пуста, ставим курсор в начало
            }
        } else {
            // Если мы на последней строке, создаём новую строку в конце документа
            content.append("")
            cursorPosition.row += 1  // Переходим на новую строку
            cursorPosition.col = 0    // Ставим курсор в начало новой строки
        }
    }


    func moveCursorUp() {
        // Если не первая строка
        if cursorPosition.row > 0 {
            cursorPosition.row -= 1
            let prevLine = content[cursorPosition.row]
            
            // Если предыдущая строка не пуста, курсор ставится в конец этой строки
            if !prevLine.isEmpty {
                cursorPosition.col = prevLine.count
            } else {
                // Если строка пуста, курсор ставится в начало
                cursorPosition.col = 0
            }
        }
    }


    // Включение режима ввода текста
    func startInsertMode() {
        isInInsertMode = true
        print("Вы вошли в режим ввода текста. Для выхода из режима ввода введите /e.")
        while isInInsertMode {
            clearScreen()  // Очистить экран перед каждым обновлением
            displayContent() // Отображаем актуальный контент
            print("\nВведите текст (для новой строки используйте Enter, для выхода введите /e): ", terminator: "")

            guard let inputText = readLine() else { continue }

            if inputText == "/e" {
                isInInsertMode = false
                return
            }

            let line = content[cursorPosition.row]
            let left = line.prefix(cursorPosition.col)
            let right = line.suffix(line.count - cursorPosition.col)

            content[cursorPosition.row] = left + inputText + right
            cursorPosition.col += inputText.count

            if inputText.contains("\n") {
                let lines = inputText.split(separator: "\n")
                for (index, line) in lines.dropFirst().enumerated() {
                    let newLine = indent + line // Добавляем отступ на новых строках
                    content.insert(newLine, at: cursorPosition.row + 1 + index)
                    cursorPosition.row += 1
                    cursorPosition.col = indent.count
                }
            }
        }
    }

    // Удаление символа слева от курсора
    func deleteCharacterLeft() {
        if cursorPosition.col > 0 {
            var line = content[cursorPosition.row]
            let index = line.index(line.startIndex, offsetBy: cursorPosition.col - 1)
            line.remove(at: index)
            content[cursorPosition.row] = line
            cursorPosition.col -= 1
        } else if cursorPosition.row > 0 {  // Если курсор на первой позиции строки, переходим на предыдущую строку
            // Убираем пустую строку
            content.remove(at: cursorPosition.row)
            cursorPosition.row -= 1  // Переходим на предыдущую строку
            cursorPosition.col = content[cursorPosition.row].count  // Перемещаем курсор в конец предыдущей строки
        }
    }

    // Сохранение файла
    func saveToFile() {
        guard let fileName = currentFile else {
            print("Нет открытого файла для сохранения.")
            return
        }

        let fileManager = FileManager.default
        let currentDirectory = fileManager.currentDirectoryPath
        let filePath = "\(currentDirectory)/\(fileName)"

        let textToSave = content.joined(separator: "\n")

        do {
            try textToSave.write(toFile: filePath, atomically: true, encoding: .utf8)
            print("Файл сохранен как \(filePath).")
        } catch {
            print("Ошибка при сохранении файла: \(error)")
        }
    }
}

let editor = TerminalEditor()
editor.start()
*/
/*
 📂 SwiftTextEditor
 │
 ├── 📂 Models
 │   ├── Document.swift
 │   ├── PlainTextDocument.swift
 │   ├── MarkdownDocument.swift
 │   ├── RichTextDocument.swift
 │   ├── User.swift
 │   └── RoleManager.swift
 │
 ├── 📂 Patterns
 │   ├── FactoryPattern.swift
 │   ├── AdapterPattern.swift
 │   ├── DecoratorPattern.swift
 │   ├── CommandPattern.swift
 │   ├── StrategyPattern.swift
 │   ├── ObserverPattern.swift
 │   └── SingletonPattern.swift
 │
 ├── 📂 Storage
 │   ├── LocalStorage.swift
 │   └── CloudStorage.swift
 │
 ├── 📂 Commands
 │   ├── InsertTextCommand.swift
 │   ├── DeleteTextCommand.swift
 │   └── UndoRedoManager.swift
 │
 ├── 📂 CLI
 │   └── CLIHandler.swift
 │
 └── main.swift
 */

/*
 План выполнения лабораторной работы №2 ("OOP Patterns")
 Мы будем постепенно добавлять функционал, используя принципы объектно-ориентированного программирования (ООП) и паттерны проектирования.

 📌 Этап 1: Базовая система управления документами
 🔹 Функциональность:
 ✅ Реализация классов Document, PlainTextDocument, MarkdownDocument, RichTextDocument.
 ✅ Реализация фабричного паттерна (Factory Pattern) для создания разных типов документов.
 ✅ Возможность создания, открытия, редактирования, сохранения и удаления документов.
 ✅ Поддержка форматов: TXT, JSON, XML.
 ✅ CLI (Command Line Interface) для взаимодействия с пользователем.
 ✅ Корректное хранение файлов в заданной директории.

 📌 Используемые паттерны:
 ✔ Factory Method (для создания документов разных типов).

 📌 Этап 2: Редактирование и форматирование текста
 🔹 Функциональность:
 ✅ Добавление текста, удаление, изменение.
 ✅ Возможность форматирования текста (жирный, курсив, подчёркнутый).
 ✅ Реализация копирования, вырезания, вставки текста.
 ✅ Поиск текста в документе.

 📌 Используемые паттерны:
 ✔ Decorator Pattern (для форматирования текста).

 📌 Этап 3: Система "Отменить / Повторить" (Undo/Redo)
 🔹 Функциональность:
 ✅ Добавление истории изменений документа.
 ✅ Реализация команд "Отмена" (Undo) / "Повторить" (Redo).

 📌 Используемые паттерны:
 ✔ Command Pattern (для управления действиями пользователя).

 📌 Этап 4: Управление пользователями и правами доступа
 🔹 Функциональность:
 ✅ Добавление ролей пользователей (Viewer, Editor, Admin).
 ✅ Ограничение доступа для пользователей в зависимости от их роли.
 ✅ Реализация наблюдателя для уведомления пользователей об изменениях.

 📌 Используемые паттерны:
 ✔ Strategy Pattern (разные уровни доступа).
 ✔ Observer Pattern (уведомления об изменениях).

 📌 Этап 5: Хранение документов и экспорт в разные форматы
 🔹 Функциональность:
 ✅ Возможность сохранения в локальные файлы, базу данных, облако.
 ✅ Экспорт в разные форматы (TXT, JSON, XML).
 ✅ Конвертация между форматами (Markdown <-> PlainText <-> RichText).

 📌 Используемые паттерны:
 ✔ Adapter Pattern (для работы с разными форматами).
 ✔ Strategy Pattern (для выбора места хранения).

 📌 Этап 6: Настройки и персонализация
 🔹 Функциональность:
 ✅ Глобальные настройки темы, шрифта, размера текста.
 ✅ Реализация истории редактирования документа.

 📌 Используемые паттерны:
 ✔ Singleton Pattern (для хранения настроек).

 📌 Финальный этап: Тестирование и подготовка отчёта
 ✅ Тестирование системы (unit-тесты).
 ✅ Подготовка UML-диаграммы.
 ✅ Оформление README.md (описание проекта, инструкции).
 ✅ Загрузка кода в GitHub.

 🎯 Итог:
 🔹 Получится гибкий и удобный консольный текстовый редактор с расширенной функциональностью.
 🔹 Используем основные паттерны ООП, что обеспечит масштабируемость кода.
 🔹 Все функции добавляются поэтапно, упрощая разработку и тестирование.

 Как тебе такой план? 😎🚀
 */


